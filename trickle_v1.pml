#define TIMER_INIT -1
#define NUM_NODES 5
#define NODE_0 0
#define NODE_1 1
#define NODE_2 2
#define NODE_3 3
#define NODE_4 4
#define INIT 0
#define FASTFLOODING 1
#define isneigbor(v,n) (v>>n&1)
mtype={ver_msg};
chan ch_broadcast_message[NUM_NODES]=[NUM_NODES] of {mtype,int,int,int};
#define I_MAX 100
#define I_MIN 10
#define K 2
#define set(tmr,value) tmr=value
#define expire(tmr) (tmr<=0)
#define tick(tmr) if ::(tmr>=0)->tmr=tmr-1::else fi
int clock[NUM_NODES];
int clockt[NUM_NODES];
int ver_no[NUM_NODES];
proctype N(byte node_id;int n_incoming;int incoming;int n_outgoing;int outgoing) {
int i_current,c,t,i,j;
int from,to,ver_no_recvd;
int state;
state=INIT;
i_current=I_MIN;
t=i_current/2;
interval_begin:
	atomic
	{
		c=0;		
		set(clock[node_id],i_current-t);
	}
state=FASTFLOODING;
atomic
{
	do
	::expire(clock[node_id])->		
		break;
	od;q
}
atomic {
i=0;
j=0;
transmit:
if
::(c<K)->	
	if
	::ver_no[node_id]=0;
	::ver_no[node_id]=0;
	::ver_no[node_id]=0;
	::ver_no[node_id]=0;
	::ver_no[node_id]=1;
	fi;
     do
	::(i> NUM_NODES-1) ->break;
	:: (i<=NUM_NODES-1) ->
		 if
                 :: ( isneigbor(outgoing,i))->
			 	ch_broadcast_message[i] !ver_msg,node_id,i,ver_no[node_id];
				printf("Sending broadcast message from %d to %d\n",node_id,i);
				j++;					
	         ::else->	
		fi;	
		i++;
	::(j>n_outgoing-1)->break;  
	od;
	
::else->skip;
fi;
}

atomic
{	
	set(clockt[node_id],t);
	do
	::expire(clockt[node_id])->
		printf("An Sub interval is completed for node %d\n",node_id);	
		break;
	::ch_broadcast_message[node_id]?ver_msg,from,to,ver_no_recvd;
	  printf("A message  is recieved from %d to %d in node %d",from,to,ver_no_recvd);
	   	
		if
		::(ver_no[node_id]==ver_no_recvd)->
			c=c+1;
            i_current=i_current*2;
	        if
	        ::(i_current>I_MAX)
		        i_current=I_MAX;
	        ::else->skip;
	        fi;
	        t=i_current/2;
            atomic
	        {
		        c=0;		
		        set(clock[node_id],i_current-t);
	        }
            atomic
            {
	            do
	            ::expire(clock[node_id])->		
		            break;
	            od;
            }
            goto transmit;
		::else->printf("Inconsistency occurred at node %d",from);
		  ver_no[node_id]=ver_no_recvd;
          i_current=I_MIN;
          t=i_current/2;
          goto transmit;   
		fi;
	od;
	
}	

atomic {
	printf("An interval is completed\n")	
	goto interval_begin;
	}	
}
proctype timers()
{
  end_x:do
	::timeout->
	   atomic {
	 	
		tick(clock[NODE_0]);
		tick(clock[NODE_1]);
		tick(clock[NODE_2]);
		tick(clock[NODE_3]);
		tick(clock[NODE_4]);
		tick(clockt[NODE_0]);
		tick(clockt[NODE_1]);
		tick(clockt[NODE_2]);
		tick(clockt[NODE_3]);
		tick(clockt[NODE_4]);
		}					 	       
 	od;	
}
init {
	
	
	  
	/*Modified Multihop Topology */

	/*atomic {
		
	  	set(clock[0],TIMER_INIT);
		set(clock[1],TIMER_INIT);
		set(clock[2],TIMER_INIT);
		set(clock[3],TIMER_INIT);
		set(clock[4],TIMER_INIT);
		set(clockt[0],TIMER_INIT);
		set(clockt[1],TIMER_INIT);
		set(clockt[2],TIMER_INIT);
		set(clockt[3],TIMER_INIT);
		set(clockt[0],TIMER_INIT);
		run N(0,0,0,1,2);
		run N(1,2,5,2,5);
		run N(2,2,10,2,10);
		run N(3,2,20,2,20);
		run N(4,1,8,1,8);   
	        run timers();	
		} */ 
	/*Star Topology */

	atomic {
		set(clock[0],TIMER_INIT);
		set(clock[1],TIMER_INIT);
		set(clock[2],TIMER_INIT);
		set(clock[3],TIMER_INIT);
		set(clock[4],TIMER_INIT);
		set(clockt[0],TIMER_INIT);
		set(clockt[1],TIMER_INIT);
		set(clockt[2],TIMER_INIT);
		set(clockt[3],TIMER_INIT);
		set(clockt[0],TIMER_INIT);
		run N(0,4,30,4,30);
		run N(1,1,1,1,1);
		run N(2,1,1,1,1);
		run N(3,1,1,1,1);
		run N(4,1,1,1,1);   
	        run timers();
	
	}	
		
}

