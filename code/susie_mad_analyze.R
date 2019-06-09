library(susieR)

susie_mad_analyze = function(y, order, use_mad, mad){
  s = susie_trendfilter(y=y, order=order, use_mad=use_mad, mad=mad)
  return(s)
}
