function [w,lw]=grid(w0,T,nw,ns,vmu,vsi,G)

% Wealth Grid for use in DORS 2020
% There is in fact the "normal" grid w and the grid of natural logs of w, i.e. lw.

 %min and max of averages and standard deviations of portfolios
  mumin=min(vmu);  
  mumax=max(vmu);
  simax=max(vsi);
      
 %Minimum and maximum wealth percentages, taking into account additions or withdrawals.
  wmin = w0*exp( (mumin - 0.5*simax*simax)*T - ns*simax*sqrt(T) );
  wmax = w0*exp( (mumax - 0.5*simax*simax)*T + ns*simax*sqrt(T) );
   
 % wealth index grid
  lw = linspace(log(wmin),log(wmax),nw)';
  
 %adjustment to have ln(G) between two points
  lG=log(G);
  I=find(lw>lG,1);
  
  lw_lower = lw(I-1);                          
  lw_upper = lw(I);
  lw_mid = lw_lower + (lw_upper-lw_lower)/2;
  
 % difference between medium and lG
  dif = lG - lw_mid;
  
 %adjustment
  lw = lw + dif;
  
 %grid in dollars
  w=exp(lw);
   
end
