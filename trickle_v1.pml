#define TIMER_INIT -1
#define NUM_NODES 3
#define NODE_ID0 0
#define NODE_ID1 1
#define NODE_ID2 2
#define N_INCOMING0 2
#define N_INCOMING1 1
#define N_INCOMING2 1
#define INCOMING0 6
#define INCOMING1 1
#define INCOMING2 1
#define N_OUTGOING0 2
#define N_OUTGOING1 1
#define N_OUTGOING2 1
#define OUTGOING0 6
#define OUTGOING1 1
#define OUTGOING2 1  
#define isneigbor(v,n) (v>>n&1)
mtype={ver_msg};
chan ch_broadcast_message[NUM_NODES]=[NUM_NODES] of {mtype,int,int,int};
#define I_MAX 100
#define I_MIN 10
#define K 2
#define IS 1
#define FFS 2
#define LFS
#define set(tmr,value) tmr=value
#define expire(tmr) (tmr<=0)
#define tick(tmr) if ::(tmr>=0)->tmr=tmr-1::else fi
int clock[NUM_NODES];
int clockt[NUM_NODES];
int ver_no[NUM_NODES];
proctype N(byte node_id;int n_incoming;int incoming;int n_outgoing;int outgoing) {
int interval,c,t,i,j;
int from,to,ver_no_recvd;
/* Procedure Rule 1 */
INIT:
interval=I_MIN;
NEW_INTERVAL:
atomic
{
printf("Entered new interval state at node %d\n",node_id);		
c=0;	
set(clock[node_id],interval);
}
FLOODINGSTATE:
atomic
{
printf("Entered flooding state at node %d\n",node_id);
i=0;
j=0;
if
::(c<K)->
/* Non deterministically changing the version no of  the current node to 
indicate a version change at some moment to incorporate inconsistency  in the model */	
if
::ver_no[node_id]=0;
::ver_no[node_id]=0;
::ver_no[node_id]=0;
::ver_no[node_id]=0;
::ver_no[node_id]=0;
::ver_no[node_id]=0;
::ver_no[node_id]=0;
::ver_no[node_id]=0;	    
::ver_no[node_id]=0;
::ver_no[node_id]=0;
::ver_no[node_id]=0;
::ver_no[node_id]=0;
::ver_no[node_id]=0;
::ver_no[node_id]=0;
::ver_no[node_id]=0;
::ver_no[node_id]=0;        
::ver_no[node_id]=1;
fi;
/* Procedure Rule 3 */
/* Modelling Pattern for Broadcast */
do
::(i> NUM_NODES-1) ->break;
:: (i<=NUM_NODES-1) ->
if
::( isneigbor(outgoing,i))->
ch_broadcast_message[i] !ver_msg,node_id,i,ver_no[node_id];
printf("Sending broadcast message from %d to %d\n",node_id,i);
j++;					
::else->skip;
fi;	
i++;
::(j>n_outgoing-1)->break;  
od;	
::else->skip;
fi;  
/* Procedure Rule 4 */
do
::expire(clock[node_id])->		
break;
::ch_broadcast_message[node_id]?ver_msg,from,to,ver_no_recvd;
printf("A message  is recieved from %d to %d in node %d\n",from,to,node_id);
/* Procedure Rule 2 (Consistent)*/
if
::(ver_no[node_id]==ver_no_recvd)-> 
c=c+1;
interval=interval*2;
if
::(interval>I_MAX)->  
interval=I_MAX;
::else->skip
fi; 
/* Procedure Rule 5 (Inconsistent)*/      
::else->printf("Inconsistency occurred at node %d\n",from);
ver_no[node_id]=ver_no_recvd; 
interval=I_MIN;  
fi;
od;	
}
/* Procedure Rule 4 */
goto NEW_INTERVAL;

}
proctype timers()
{
end_x:do
::timeout->
atomic {

tick(clock[NODE_ID0]);
tick(clock[NODE_ID1]);
tick(clock[NODE_ID2]);
tick(clock[NODE_ID3]);
tick(clock[NODE_ID4]);
}					 	       
od;	
}
init {


/*Star Topology */

atomic {
set(clock[0],TIMER_INIT);
set(clock[1],TIMER_INIT);
set(clock[2],TIMER_INIT);
run N(NODE_ID0,N_INCOMING0,INCOMING0,N_OUTGOING0,OUTGOING0);
run N(NODE_ID1,N_INCOMING1,INCOMING1,N_OUTGOING1,OUTGOING1);
run N(NODE_ID2,N_INCOMING2,INCOMING2,N_OUTGOING2,OUTGOING2);   
run timers();
}	
}
}