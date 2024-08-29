/*#define VERIFICATION 1*/
#define NODATA 1
#define MAXNODE 5
#define MAXCHANNEL 5
#define MAXITERATION 5
#define TDP 640
#define TRP 640
#define TG 300
#define TFRAME 12580
#define TFRAME1 13
mtype={PING,TDI,REQ,DATA};
chan tda_channel[MAXCHANNEL]=[10] of{mtype,byte,byte,int};
int timer[5],slottimer;
#define set(tmr,value) tmr=value
#define expire(tmr) (tmr<=0)
#define tick(tmr) if ::(tmr>=0)->tmr=tmr-1::else fi
inline tpSelect2()
{
	if
	:: tp=5160;
	:: tp=5150;
	:: tp=5140;
	:: tp=5130;
	:: tp=5120;
	:: tp=5110;
	:: tp=5100;
	:: tp=5090;
	:: tp=5080;
	:: tp=5070;
	:: tp=5060;
	:: tp=5050;
	:: tp=5040;
	:: tp=5030;
	:: tp=5020;
	:: tp=5010;
	:: tp=5000;
	:: tp=4990;
	:: tp=4980;
	:: tp=4970;
	:: tp=4960;
	:: tp=4950;
	:: tp=4940;
	:: tp=4930;
	:: tp=4920;
	:: tp=4910;
	:: tp=4900;
	:: tp=4890;
	:: tp=4880;
	:: tp=4870;
	:: tp=4860;
	fi;	
}
proctype timers()
{
do
	::timeout->
	   atomic {
	    tick(timer[0]);
	 	tick(timer[1]);
	 	tick(timer[2]);
	 	tick(timer[3]);
	 	tick(timer[4]);
	 	tick(slottimer);
		}					 	       
 	od;
 }	
proctype G(byte node_id)
{
	byte i=1;
	int Tp[MAXNODE],Ttx[MAXNODE],Tdp[MAXNODE],Tg[MAXNODE],Tpdiff,tp,err;
	byte source,dest;
	/*bool multipath=false;*/
	int msg1;
	atomic
	{
	tpSelect2();
	do
	:: (i< MAXNODE)->
	   tda_channel[i]! PING,node_id,i,NODATA;
PING_STATE:	    
	   if
	   ::tda_channel[node_id]? PING(source,dest,msg1)->
	   	 Tp[i]=tp;
	   	 Tdp[i]=TDP;
	   	 Tg[i]=TG;   
	   fi;
	    i=i+1;   
	:: (i>=MAXNODE)->
		break;
	od;
	}
rpt:
TRANSMIT_COMPUTE:
	atomic
	{
		i=1;
		Ttx[i]=0;
		i=i+1;
		do
		:: (i< MAXNODE)->		
		    if
		    ::(Tp[i]-Tp[i-1]<=0)
		       Tpdiff=0;
		     :: else->
		        Tpdiff=Tp[i]-Tp[i-1];
		      fi;    
	   		Ttx[i]=Ttx[i-1]+Tdp[i-1]+Tg[i-1]-(2*Tpdiff);	
	    	i=i+1;   
		:: (i>=MAXNODE)->
			break;
		od;
	}
	atomic
	{
		i=1;
	do
	:: (i< MAXNODE)->
	   tda_channel[i]! TDI,node_id,i,Ttx[i]; 
TDI_STATE:	   
	    i=i+1;   
	:: (i>=MAXNODE)->
		break;
	od;
	}
rpt2:
REQUEST_STATE:		
	atomic
	{
		i=1;	
		do
		:: (i< MAXNODE)->
	   	tda_channel[i]! REQ,node_id,i,Tp[i];   	 
	    i=i+1;   
		:: (i>=MAXNODE)->
		break;
		od;
	#ifdef VERIFICATION	
		set(slottimer,TFRAME*(MAXNODE-1));
	#else
		set(slottimer,TFRAME1*(MAXNODE-1));
	#endif	
	do
	::tda_channel[node_id]? DATA(source,dest,msg1)->
	     if
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=160;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   :: err=0;
	   fi;
	  	if
	  	::(err> TG/2)->
	  	   expire(slottimer);
	  	   i=1;
	  	   tpSelect2();
	  	   do
	  	   ::(i< MAXNODE)->
	  	      Tp[i]=tp;
	  	      i=i+1;
	  	    :: (i>=MAXNODE)->
	  	        break;
	  	   od;
	  	   goto rpt;
	  	 :: else->skip;   
	  	fi;
	 ::expire(slottimer)-> 	
	   goto rpt2;	 
	od;	
	}
}
proctype N(byte node_id)
{
	int tp,ttx,msg1,msg2;
	byte i=0;
	byte source,dest;
	bool multipath=false;
	do
	::tda_channel[node_id]? PING(source,dest,msg1);
	  /*if
	  ::(multipath==false)->
	    multipath=true;*/
PING_ACK_STATE:	    
	 		tda_channel[i]! PING(dest,source,NODATA);
	:: tda_channel[node_id]? TDI(source,dest,msg1);
UPDATE_TTX_STATE:	 
	   ttx=msg1;	
	:: tda_channel[node_id]? REQ(source,dest,msg1);
REQUEST_PROCESS_STATE:	
	   tp=msg1;
	   if
	   :: msg2=1234;
	   :: msg2=1231;
	   :: msg2=1235;
	   :: msg2=1232;
	   :: msg2=1233;
	   fi;
	   #ifdef VERIFICATION
	   	set(timer[node_id],(TRP+ttx+tp+tp));
	   #else
	    set(timer[node_id],(TRP+ttx+tp+tp)/1000);
	   #endif  	
	   if
	   ::(expire(timer[node_id]))->
DATA_TRANSMIT_STATE:	   
	   	tda_channel[source]! DATA(dest,source,msg2);
	   fi		   
	 od;	
	 	/*multipath=false;
	 fi;*/ 
}
init {
atomic
{
	run G(0);
	run N(1);
	run N(2);
	run N(3);
	run N(4);
	run timers();
}	
}




