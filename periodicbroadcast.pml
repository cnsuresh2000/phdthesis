#define TIMER_INIT -1
#define NUM_NODES 4
#define NODE_0 0
#define NODE_1 1
#define NODE_2 2
#define NODE_3 3
#define isneighbour(v,n) (v>>n&1)
mtype={periodic_msg};
chan ch_broadcast_message[NUM_NODES]
=[NUM_NODES] of {mtype,byte};
#define ADVERTISEMENT_INTERVAL 10
#define set(tmr,value) tmr=value
#define expire(tmr) (tmr<=0)
#define tick(tmr) if ::(tmr>=0)->tmr=tmr-1
::else fi
int advertise_timer[NUM_NODES];

proctype N(byte node_id;
byte n_incoming;byte incoming;
byte n_outgoing;byte outgoing) {
byte i,j,k,source;
end_nxt_period:				
atomic {
i=0;
j=0;
set(advertise_timer[node_id],
ADVERTISEMENT_INTERVAL);
do
::(i> NUM_NODES-1) ->break;
:: (i<=NUM_NODES-1) ->
if
::(isneighbour(outgoing,i))->
ch_broadcast_message[i]!periodic_msg,i;
printf("Advertisement Message Sent from %d 
to %d \n",node_id,i);
j++;					
::else->	
fi;	
i++;
od;
}             	    
do
::ch_broadcast_message[node_id] ? 
periodic_msg,source -> 	
::(expire(advertise_timer[node_id]))->		
goto end_nxt_period;			
od;			      		
}
proctype timers()
{
do
::timeout->
atomic{
tick(advertise_timer[NODE_0]);
tick(advertise_timer[NODE_1]);
tick(advertise_timer[NODE_2]);
tick(advertise_timer[NODE_3]);		
}             
od;	
}
init {
atomic {
set(advertise_timer[NODE_0],TIMER_INIT);
set(advertise_timer[NODE_1],TIMER_INIT);
set(advertise_timer[NODE_2],TIMER_INIT);	
set(advertise_timer[NODE_3],TIMER_INIT);
run timers();
run N(0,1,2,1,2);
run N(1,3,13,3,13);
run N(2,1,2,1,2);
run N(3,1,2,1,2);	
}
}
