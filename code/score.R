compute_mse = function(mu_est, mu_true){
  if (length(mu_est)!=length(mu_true)){
    n = length(mu_true)
    mu_est = mu_est[1:n]
  }
  return(mean((mu_est-mu_true)^2))
}