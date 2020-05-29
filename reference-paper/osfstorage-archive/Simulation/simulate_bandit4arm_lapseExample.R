# to simulate bandit4arm_lapse model - this example is for HC under safe. You can make whatever you want by changing the output it reads in

rm(list=ls() )

library(R.matlab)
library(truncnorm)  # truncated normal


set.seed(43210)  # to set a seed value


#load the fitted params
load("C:/Whereever/You/Saved/The/FittingOutput.RData")

# load master_prob.mat from a Dropbox link
rewlos_tmp = readMat("master_prob.mat")

rew_prob = as.matrix(rewlos_tmp$master.money.prob)
pun_prob = as.matrix(rewlos_tmp$master.pain.prob)

Tsubj = 200  # use the first 200 trials. Note that there are 600 trials in the master_prob.mat file
numSubjs = length(output2_HCS$allIndPars$Arew)

rew_prob = data.frame(rew_prob1=rew_prob[1, 1:Tsubj],
                      rew_prob2=rew_prob[2, 1:Tsubj],
                      rew_prob3=rew_prob[3, 1:Tsubj],
                      rew_prob4=rew_prob[4, 1:Tsubj])

pun_prob = data.frame(pun_prob1=pun_prob[1, 1:Tsubj],
                      pun_prob2=pun_prob[2, 1:Tsubj],
                      pun_prob3=pun_prob[3, 1:Tsubj],
                      pun_prob4=pun_prob[4, 1:Tsubj] )



#Base on real subjects

#change the below for e.g. HC etc.

Arew = output2_HCS$allIndPars$Arew
Apun = output2_HCS$allIndPars$Apun
R    = output2_HCS$allIndPars$R
P    = output2_HCS$allIndPars$P
xi   = output2_HCS$allIndPars$xi
all_simul_pars = cbind(Arew, Apun, R, P, xi)


allData = NULL  # all simulated data will be saved to this variable

initV = rep(0.0, 4);  # initial values
pD = rep(0.25, 4);    # initial probability of choosing each deck

for (i in 1:numSubjs) {
  
  # simulate choice on trial#1...
  tmpDeck = sample(1:4, size=1, replace=T, prob=pD)
  tmpData = data.frame(trial=NULL, deck=NULL, gain=NULL, loss=NULL, subjID=NULL)
  
  Qr = initV
  Qp = initV
  
  for (t in 1:Tsubj) {
    
    # select a deck
    tmpDeck = sample(1:4, size = 1, replace = T, prob = pD)
    
    # compute   tmpRew and tmpPun
    tmpRew = sample(c(0,1), size=1, replace=T, prob = c(1-rew_prob[t, tmpDeck], rew_prob[t, tmpDeck]))
    tmpPun = sample(c(0,-1), size=1, replace=T, prob = c(1-pun_prob[t, tmpDeck], pun_prob[t, tmpDeck]))
    
    # compute PE and update values..
    PEr     = R[i]*tmpRew - Qr[ tmpDeck];
    PEp     = P[i]*tmpPun - Qp[ tmpDeck];
    PEr_fic = -Qr;
    PEp_fic = -Qp;
    
    # store chosen deck Q values (rew and pun)
    Qr_chosen = Qr[ tmpDeck];
    Qp_chosen = Qp[ tmpDeck];
    
    # First, update Qr & Qp for all decks w/ fictive updating   
    Qr = Qr + Arew[i] * PEr_fic;
    Qp = Qp + Apun[i] * PEp_fic;
    # Replace Q values of chosen deck with correct values using stored values
    Qr[ tmpDeck] = Qr_chosen + Arew[i] * PEr;
    Qp[ tmpDeck] = Qp_chosen + Apun[i] * PEp;
    
    # Q(sum)
    Qsum = Qr + Qp; 
    
    # update pD (for t+1)
    for (d in 1:4) {
      pD[d] = exp( Qsum[d] ) / sum( exp(Qsum) ) 
    }
    
    # xi
    pD = pD * (1-xi[i]) + xi[i]/4  #choice[i,t] ~ categorical( softmax(Qsum)*(1-xi[i]) + xi[i]/4 );
    
    tmpData[t, "trial"] = t
    tmpData[t, "choice"] = tmpDeck
    tmpData[t, "gain"] = tmpRew
    tmpData[t, "loss"] = tmpPun
    tmpData[t, "subjID"] = i
    
  }
  
  allData = rbind(allData, tmpData)
}

cat("all done \n")

# write allData as a txt file (0bv change the name if you change what you are reading in)
write.table(allData, paste0("bandit4_Lapse_testData__HCS_N", numSubjs, ".txt"), row.names = F, col.names = T, sep = "\t")
write.table(all_simul_pars, paste0("bandit4_Lapse_HCS_N", numSubjs, ".txt"), row.names = F, col.names = T, sep = "\t")

