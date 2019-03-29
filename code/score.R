compute_mse = function(mu_est, mu_true){
  if (length(mu_est)!=length(mu_true)){
    n = length(mu_true)
    J = floor(log2(2*n))
    mu_reflect = c(mu_true, rev(mu_true))
    mu_reflect = mu_reflect[1:2^J]
    mu_reflect = c(mu_reflect, rev(mu_reflect))
    mu_true = mu_reflect
  }
  return(mean((mu_est-mu_true)^2))
}