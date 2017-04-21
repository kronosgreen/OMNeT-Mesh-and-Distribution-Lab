//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
// 

package nsexample;

simple Workstation

{
    parameters:
        @display("i=block/routing");

    gates:
        input in[];
        output out[];
}


simple MasterWorkstation extends Workstation

{
    @class(MasterWorkstation);
}

simple ChildWorkstation extends Workstation
{
    @class(ChildWorkstation);
}

simple BusMasterWorkstation extends Workstation
{
    @class(BusMasterWorkstation);
}

simple BusChildWorkstation extends Workstation
{
    @class(BusChildWorkstation);
}

simple MeshWorkstation extends Workstation
{
    @class(MeshWorkstation);
}


network DistributionNetwork

{
    parameters:
        int numOfDevices;

    submodules:
        master1: MasterWorkstation {
            parameters:
                @display("p=20,20");
        }
        master2: MasterWorkstation {
            parameters:
                @display("p=200,20");
        }
        endUser[numOfDevices-2]: ChildWorkstation {
            parameters:
                @display("p=50,40,m,5,30,40");
        }

    connections:
        for i=0..numOfDevices-3 {
            master1.out++ --> {  delay = 100ms; } --> endUser[i].in++;
            master1.in++ <-- {  delay = 100ms; } <-- endUser[i].out++;
        }
        
        for j=0..numOfDevices-3 {
            master2.out++ --> {  delay = 100ms; } --> endUser[j].in++;
            master2.in++ <-- {  delay = 100ms; } <-- endUser[j].out++;
        }
        
}

network BusNetwork

{
    parameters:
        int numOfDevices;

    submodules:
        master1: BusMasterWorkstation {
            parameters:
                @display("p=20,20");
        }
        master2: BusMasterWorkstation {
            parameters:
                @display("p=200,20");
        }
        endUser[numOfDevices-2]: BusChildWorkstation {
            parameters:
                @display("p=50,40,m,5,30,40");
        }

    connections:
        master1.out++ --> {  delay = 1000ms; } --> master2.in++;
        master1.in++ <-- {  delay = 1000ms; } <-- master2.out++;
        
        master2.out++ --> {  delay = 1000ms; } --> master1.in++;
        master2.in++ <-- {  delay = 1000ms; } <-- master1.out++;
        
        for i=0..numOfDevices-3 {
            master1.out++ --> {  delay = 1000ms; } --> endUser[i].in++;
        }
        
        for j=0..numOfDevices-3 {
            master2.out++ --> {  delay = 1000ms; } --> endUser[j].in++;
        }
        
}

network MeshNetwork

{
    parameters:
        int numOfDevices;

    submodules:
        endUser[numOfDevices]: MeshWorkstation;
    connections:
        for i=0..numOfDevices-2, for j=i..numOfDevices-2 {
            endUser[i].out++ --> {  delay = 100ms; } --> endUser[j+1].in++;
            endUser[i].in++ <-- {  delay = 100ms; } <-- endUser[j+1].out++;
        }
}

