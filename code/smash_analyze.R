library(smashr)

smash.wavelet = function(mu_true, y,model="gaus",filter.number=fnum,family=family){
  n = length(y)
  y_reflect = c(y, rev(y))
  J = floor(log2(2*n))
  y_reflect = y_reflect[1:2^J]
  y_reflect = c(y_reflect, rev(y_reflect))
  s = smash(y,model="gaus",filter.number=fnum,family=family)
  
  mu_reflect = c(mu_true, rev(mu_true))
  mu_reflect = mu_reflect[1:2^J]
  mu_reflect = c(mu_reflect, rev(mu_reflect))
  
  return(list(mu_reflect=mu_reflect, y_reflect=y_reflect, s=s))
}