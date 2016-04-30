/* -*- Mode:C++; c-file-style:"gnu"; indent-tabs-mode:nil; -*- */
/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation;
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */
#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/applications-module.h"
#include "ns3/wifi-module.h"
#include "ns3/mobility-module.h"
#include "ns3/ipv4-global-routing-helper.h"
#include "ns3/internet-module.h"
#include "ns3/flow-monitor-module.h"
#include "ns3/random-variable-stream.h"
#include "ns3/propagation-loss-model.h"
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
using namespace ns3;
NS_LOG_COMPONENT_DEFINE ("Wifi");

int main (int argc, char *argv[])
{
// Number of nodes
uint32_t nodes = 5;
// Size of packet
uint32_t packetSize = 1000;
// Number of packets
uint32_t numPackets = 10000;
// Execution time window
double StartTime = 0.0;
double StopTime = 10.0;
uint32_t rate = 0;
char rsm;
 
CommandLine cmd;
cmd.AddValue("numPackets","Number of packets",numPackets);
cmd.AddValue("packetSize","Packet size",packetSize);
cmd.AddValue("nodes","Nodes",nodes);
cmd.AddValue("rate","Rate",rate);
cmd.AddValue("rsm","Remote Station Manager", rsm);
cmd.Parse (argc,argv);

std::cout << nodes << '\t';
std::cout << numPackets << '\t';
std::cout << packetSize << '\t';

// Assign Data rate
StringValue DataRate;
switch(rate)
{
	case 1:
	DataRate = StringValue("DsssRate1Mbps");
	std::cout << 1 << '\t';
	break;

	case 2:
	DataRate = StringValue("DsssRate2Mbps");
	std::cout<< 2 << '\t';
	break;

	case 5:
        DataRate = StringValue("DsssRate5_5Mbps");
        std::cout<< 5 << '\t';
	break;

	case 11:
        DataRate = StringValue("DsssRate11Mbps");
        std::cout<< 11 << '\t';
	break;

	default:
	DataRate = StringValue("DsssRate11Mbps");
	std::cout<< "Default" << '\t';
}
// Create access point
NodeContainer wifiApNode;
wifiApNode.Create (1);

// Create station nodes
NodeContainer wifiStaNodes;
wifiStaNodes.Create (nodes);

YansWifiPhyHelper phy = YansWifiPhyHelper::Default ();
phy.Set ("RxGain", DoubleValue (0) );

// Set Propagation Delay and Loss Models
YansWifiChannelHelper channel;
channel.SetPropagationDelay ("ns3::ConstantSpeedPropagationDelayModel");
channel.AddPropagationLoss ("ns3::LogDistancePropagationLossModel","Exponent",DoubleValue(3.0));
phy.SetChannel (channel.Create ());
WifiHelper wifi = WifiHelper::Default ();
wifi.SetStandard (WIFI_PHY_STANDARD_80211b);

switch(rsm)
{
	case 'c':
	wifi.SetRemoteStationManager ("ns3::ConstantRateWifiManager","DataMode", DataRate, "ControlMode", DataRate);
	break;

	case 'a':
	wifi.SetRemoteStationManager ("ns3::AarfWifiManager");
	break;

	default:
	wifi.SetRemoteStationManager ("ns3::ConstantRateWifiManager","DataMode", DataRate, "ControlMode", DataRate);
}

// Configure MAC parameter
NqosWifiMacHelper mac = NqosWifiMacHelper::Default ();

// Configure SSID
Ssid ssid = Ssid ("Wifi");
mac.SetType ("ns3::StaWifiMac", "Ssid", SsidValue (ssid), "ActiveProbing", BooleanValue (false));
NetDeviceContainer staDevices;
staDevices = wifi.Install (phy, mac, wifiStaNodes);
mac.SetType ("ns3::ApWifiMac", "Ssid", SsidValue (ssid));
NetDeviceContainer apDevice;
apDevice = wifi.Install (phy, mac, wifiApNode);

// Configure nodes mobility
MobilityHelper mobility;

// Constant Mobility for Access Point
mobility.SetMobilityModel ("ns3::ConstantPositionMobilityModel");
mobility.Install (wifiApNode);

// Random Walk Mobility Model for Station nodes
mobility.SetMobilityModel ("ns3::RandomWalk2dMobilityModel",
"Bounds", RectangleValue (Rectangle (-500, 500, -500, 500)),
"Distance", ns3::DoubleValue (100.0));
mobility.Install (wifiStaNodes);

// Set up Internet stack
InternetStackHelper stack;
stack.Install (wifiApNode);
stack.Install (wifiStaNodes);

// Configure IPv4 address
Ipv4AddressHelper address;
Ipv4Address addr;
address.SetBase ("10.1.1.0", "255.255.255.0");
Ipv4InterfaceContainer staNodesInterface;
Ipv4InterfaceContainer apNodeInterface;
staNodesInterface = address.Assign (staDevices);
apNodeInterface = address.Assign (apDevice);
addr = apNodeInterface.GetAddress(0);

// Create traffic (UDP)
ApplicationContainer serverApp;
UdpServerHelper myServer (8001); //port 8001
serverApp = myServer.Install (wifiStaNodes.Get (0));
serverApp.Start (Seconds(StartTime));
serverApp.Stop (Seconds(StopTime));
UdpClientHelper myClient (apNodeInterface.GetAddress (0), 8001); 
myClient.SetAttribute ("MaxPackets", UintegerValue (numPackets));
myClient.SetAttribute ("Interval", TimeValue (Time ("0.002"))); //packets/s
myClient.SetAttribute ("PacketSize", UintegerValue (packetSize));
ApplicationContainer clientApp = myClient.Install (wifiStaNodes.Get(0));
clientApp.Start (Seconds(StartTime));
clientApp.Stop (Seconds(StopTime+5));

// Calculate Throughput & Delay using Flowmonitor
FlowMonitorHelper flowmon;
Ptr<FlowMonitor> monitor = flowmon.InstallAll();
Simulator::Stop (Seconds(StopTime+2));
Simulator::Run ();
monitor->CheckForLostPackets ();
Ptr<Ipv4FlowClassifier> classifier = DynamicCast<Ipv4FlowClassifier> (flowmon.GetClassifier ());
std::map<FlowId, FlowMonitor::FlowStats> stats = monitor->GetFlowStats ();
for (std::map<FlowId, FlowMonitor::FlowStats>::const_iterator i = stats.begin (); i != stats.end (); ++i)
{
double avg_throughput = i->second.rxBytes * 8.0 / (i->second.timeLastRxPacket.GetSeconds() - i->second.timeFirstTxPacket.GetSeconds())/1024/nodes ;
std::cout << avg_throughput << "\n";
}
Simulator::Destroy ();
return 0;
}
