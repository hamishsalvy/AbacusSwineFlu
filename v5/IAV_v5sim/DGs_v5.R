# FORWARD SIMULATION WITH EDITING

## Create BasePop - generations -70 to 0


#BurnIn_SPF <- read.csv("BurnIn_SPFpop2020-02-15.csv")
#BurnIn_Prod <- read.csv("BurnIn_ProdPop2020-02-15.csv")
#BurnIn_Mult <- read.csv("BurnIn_MultPop2020-02-15.csv")
#BurnIn_BW <- read.csv("BurnIn_BWpop2020-02-15.csv")

BurnIn <- list(SPFpop = BurnIn_SPF, ProdPop = BurnIn_Prod, MultPop = BurnIn_Mult, BWpop = BurnIn_BW)

### reset all populations to BurnIn read file  ### not reading a file, still needs a repeat of the previous file each time


#### changing litter size is effectively increasing the number of donor females, flushing pigs. alter for different techniques. Research ET 
# littersize <- ???


for (i in 1:10) {
  
  SPFpop <- BurnIn$SPFpop
  ProdPop <- BurnIn$ProdPop
  MultPop <- BurnIn$MultPop
  BWpop <- BurnIn$BWpop 
  
  
  for (g in 1:120){
    
    print(paste0("Gen:", g, sep = " "))
    
    ##### separate into A herd ###########
    
    if (nrow(SPFpop %>% filter(sex == "F" & herd == "A") %>% filter(age >= AgeFirstMate & age %% FarrowInt == rem)) >2) {
      
      BreedSPFA_Male <- SPFpop %>% filter (sex == "M" & herd == "A") %>% filter(age >= AgeFirstMate) 
      BreedSPFA_Male <- BreedSelection_n (BreedSPFA_Male, 10)
      
      BreedSPFA_Fem <- filter(SPFpop, sex == "F" & herd == "A") %>% filter(age >= AgeFirstMate & age %% FarrowInt == rem) %>% top_frac(0.5, merit) #crashed when using
      BreedSPFA_Fem <- BreedSelection_n (BreedSPFA_Fem, 100)
      
      newGenSPFNucA <- CreatePiglets(BreedSPFA_Male, BreedSPFA_Fem, indexSD, g, paste0("SPFA",g,"_"), littersize)
      
      newGenSPFNucA <- edit_genes(newGenSPFNucA, Edit_Efficiency, Embryo_Survival, 1) ### editing done to piglets is effectively to zygotes
      
      SPFNucA_Fem <- filter(newGenSPFNucA, sex == "F") %>% top_frac(0.25, merit) ## merit selection here
      SPFNucA_Male <- filter(newGenSPFNucA, sex == "M") %>% top_frac (0.1, merit)
      
      
      if (g == 1) { 
        A_AttemptedAllEdits <- setNames(data.frame(matrix(nrow = g, ncol =2)), c("gen", "Edits_A"))
        A_AttemptedAllEdits <- data.frame(Edits_A = nrow(filter(newGenSPFNucA, EditTrials == "1")), gen = g)
      } else  (A_AttemptedAllEdits <- rbind(A_AttemptedAllEdits, data.frame(Edits_A = nrow(filter(newGenSPFNucA, EditTrials == "1")), gen = g))) 
      
      newGenSPFNucA <- newGenSPFNucA %>% filter (fate == "1")
      
      SPFNucA_Fem <- filter(newGenSPFNucA, sex == "F") %>% top_n(200, merit) ## merit selection here
      SPFNucA_Fem1 <- newGenSPFNucA %>% filter(genoA == "a/a" & genoB == "b/b" & sex == "F")  %>% top_n(200, merit) 
      
      SPFNucA_Fem <- rbind.fill(SPFNucA_Fem, SPFNucA_Fem1) %>% distinct () #### need to adjust to allow for merit selection after fixing
      SPFNucA_Fem <- BreedSelection_n (SPFNucA_Fem, 200)
      
      SPFNucA_Male <- filter(newGenSPFNucA, sex == "M") %>% top_n (20, merit)
      SPFNucA_Male1 <-  newGenSPFNucA %>% filter(genoA == "a/a" & genoB == "b/b" &  sex == "M")  %>% top_n(20, merit)
      SPFNucA_Male <- rbind.fill(SPFNucA_Male, SPFNucA_Male1) %>% distinct ()  #### need to adjust to allow for merit selection after fix
      SPFNucA_Male <- BreedSelection_n (SPFNucA_Male, 20)
      
      
    } 
    
    ##### separate into B herd ###########
    
    if (nrow(SPFpop %>% filter(sex == "F" & herd == "B") %>% filter(age >= AgeFirstMate & age %% FarrowInt == rem)) >2) {
      
      BreedSPFB_Male <- SPFpop %>% filter (sex == "M" & herd == "B") %>% filter(age >= AgeFirstMate) 
      BreedSPFB_Male <- BreedSelection_n (BreedSPFB_Male, 10)
      
      BreedSPFB_Fem <- filter(SPFpop, sex == "F" & herd == "B") %>% filter(age >= AgeFirstMate & age %% FarrowInt == rem) 
      BreedSPFB_Fem <- BreedSelection_n (BreedSPFB_Fem, 100)
      
      newGenSPFNucB <- CreatePiglets(BreedSPFB_Male, BreedSPFB_Fem, indexSD, g, paste0("SPFB",g,"_"), littersize)
      
      newGenSPFNucB <- edit_genes(newGenSPFNucB, Edit_Efficiency, Embryo_Survival, 1) ### editing done to piglets is effectively to zygotes
      
      SPFNucB_Fem <- filter(newGenSPFNucB, sex == "F") %>% top_frac(0.25, merit) ## merit selection here
      SPFNucB_Male <- filter(newGenSPFNucB, sex == "M") %>% top_frac (0.1, merit)
      
      
      if (g == 1) { 
        B_AttemptedAllEdits <- setNames(data.frame(matrix(nrow = g, ncol =2)), c("gen", "Edits_B"))
        B_AttemptedAllEdits <- data.frame(Edits_B = nrow(filter(newGenSPFNucB, EditTrials == "1")), gen = g)
      } else  (B_AttemptedAllEdits <- rbind(B_AttemptedAllEdits, data.frame(Edits_B = nrow(filter(newGenSPFNucB, EditTrials == "1")), gen = g))) 
      
      newGenSPFNucB <- newGenSPFNucB %>% filter (fate == "1")
      
      SPFNucB_Fem <- filter(newGenSPFNucB, sex == "F") %>% top_n(200, merit) ## merit selection here
      SPFNucB_Fem1 <- newGenSPFNucB %>% filter(genoA == "a/a" & genoB == "b/b" & sex == "F")  %>% top_n(200, merit) 
      
      SPFNucB_Fem <- rbind.fill(SPFNucB_Fem, SPFNucB_Fem1) %>% distinct () #### need to adjust to allow for merit selection after fixing
      SPFNucB_Fem <- BreedSelection_n (SPFNucB_Fem, 200)
      
      SPFNucB_Male <- filter(newGenSPFNucB, sex == "M") %>% top_n (20, merit)
      SPFNucB_Male1 <-  newGenSPFNucB %>% filter(genoA == "a/a" & genoB == "b/b" &  sex == "M")  %>% top_n(20, merit)
      SPFNucB_Male <- rbind.fill(SPFNucB_Male, SPFNucB_Male1) %>% distinct ()  #### need to adjust to allow for merit selection after fix
      SPFNucB_Male <- BreedSelection_n (SPFNucB_Male, 20)
    }
    
    ########################################
    
    ##### separate into T herd ###########
    
    if (nrow(SPFpop %>% filter(sex == "F" & herd == "T") %>% filter(age >= AgeFirstMate & age %% FarrowInt == rem)) >2) {
      
      BreedSPFT_Male <- SPFpop %>% filter (sex == "M" & herd == "T") %>% filter(age >= AgeFirstMate) 
      BreedSPFT_Male <- BreedSelection_n (BreedSPFT_Male, 10)
      
      BreedSPFT_Fem <- filter(SPFpop, sex == "F" & herd == "T") %>% filter(age >= AgeFirstMate & age %% FarrowInt == rem) 
      BreedSPFT_Fem <- BreedSelection_n (BreedSPFT_Fem, 200)
      
      newGenSPFNucT <- CreatePiglets(BreedSPFT_Male, BreedSPFT_Fem, indexSD, g, paste0("SPFT",g,"_"), littersize)
      
      newGenSPFNucT <- edit_genes(newGenSPFNucT, Edit_Efficiency, Embryo_Survival, 1) ### editing done to piglets is effectively to zygotes
      
      SPFNucT_Fem <- filter(newGenSPFNucT, sex == "F") %>% top_frac(0.25, merit) ## merit selection here
      SPFNucT_Male <- filter(newGenSPFNucT, sex == "M") %>% top_frac (0.1, merit)
      
      
      if (g == 1) { 
        T_AttemptedAllEdits <- setNames(data.frame(matrix(nrow = g, ncol =2)), c("gen", "Edits_T"))
        T_AttemptedAllEdits <- data.frame(Edits_T = nrow(filter(newGenSPFNucT, EditTrials == "1")), gen = g)
      } else  (T_AttemptedAllEdits <- rbind(T_AttemptedAllEdits, data.frame(Edits_T = nrow(filter(newGenSPFNucT, EditTrials == "1")), gen = g))) 
      
      newGenSPFNucT <- newGenSPFNucT %>% filter (fate == "1")
      
      SPFNucT_Fem <- filter(newGenSPFNucT, sex == "F") %>% top_n(200, merit) ## merit selection here
      SPFNucT_Fem1 <- newGenSPFNucT %>% filter(genoA == "a/a" & genoB == "b/b" & sex == "F")  %>% top_n(200, merit) 
      
      SPFNucT_Fem <- rbind.fill(SPFNucT_Fem, SPFNucT_Fem1) %>% distinct () #### need to adjust to allow for merit selection after fixing
      SPFNucT_Fem <- BreedSelection_n (SPFNucT_Fem, 200)
      
      SPFNucT_Male <- filter(newGenSPFNucT, sex == "M") %>% top_n (20, merit)
      SPFNucT_Male1 <-  newGenSPFNucT %>% filter(genoA == "a/a" & genoB == "b/b" &  sex == "M")  %>% top_n(20, merit)
      SPFNucT_Male <- rbind.fill(SPFNucT_Male, SPFNucT_Male1) %>% distinct ()  #### need to adjust to allow for merit selection after fix
      SPFNucT_Male <- BreedSelection_n (SPFNucT_Male, 20)
    }
    
    if (g == 1) { 
      SPFpopAll <- data.frame(SPFpop) 
    } else  (SPFpopAll <- rbind.fill(SPFpopAll, SPFpop))
    
    SPF_Breeders <- rbind.fill(BreedSPFA_Fem, BreedSPFB_Fem, BreedSPFT_Fem) %>% na.omit() #only females as males are AI used
    
    if (g >= 1){ 
      
      SPFpop <-  anti_join(SPFpop, SPF_Breeders, by = "ID") %>% mutate(ID = as.character(ID)) ## removes breeding SPF breeding animals to prevent breeding in multiple tiers
      
      SPF_ProdPop_Fem <- SPFpop %>% filter(sex == "F" & herd == "A") %>% filter(age >= AgeFirstMate & age %% FarrowInt == rem) #%>% top_frac(0.5, merit)
      ### removing selection affects flow massively & speeds code ## must be 0 if same selection is performed above for SPFA!
      
      SPF_ProdPop_Fem <- BreedSelection_frac (SPF_ProdPop_Fem, 0.25) #### could go back to 0.25
      
      SPFpop <-  anti_join(SPFpop, SPF_ProdPop_Fem, by = "ID") ## SPFpop permanently loses the pigs transferred to ProdPop 
      
      SPF_ProdPop_Males <- SPFpop %>% filter(sex == "M" & herd == "A") %>% filter(age >= AgeFirstMate) # %>% top_frac(0.1, merit) 
      
      SPF_ProdPop_Males <- BreedSelection_n (SPF_ProdPop_Males, 50)
      
      #SPFpop <-  anti_join(SPFpop, SPF_ProdPop_Males, by = "ID") ## removes prod pop males from the SPFpop ### don't need as AI is performed on SPFpop
      
      ProdPop <- rbind.fill(ProdPop, SPF_ProdPop_Fem) ### No males from SPF stored as used by AI only . Only PN bred males will be in PN ######
      
      Prod_Males <- rbind.fill(ProdPop, SPF_ProdPop_Males) %>% filter(sex == "M") %>% filter(age >= AgeFirstMate) #%>% top_frac(0.15, merit) # selects for males from ProdPop and SPF Nucleus 
      Prod_Males <- BreedSelection_n (Prod_Males, 25)
      
      Prod_Females <- ProdPop %>% filter(sex == "F") %>% filter(age >= AgeFirstMate & age %% FarrowInt == rem) 
      Prod_Females <- BreedSelection_n(Prod_Females, 800) %>% mutate(ID = as.character(ID))
      
      ############## CHECK THIS WORKS CORRECTLY ####################
      
      NewProdPop <- CreatePiglets(Prod_Males, Prod_Females, indexSD, g, paste0("Prod",g,"_"), littersize)
      
      NewProd_Females <- NewProdPop %>% filter(sex == "F") %>% top_frac(0.2, merit) 
      NewProd_Females1 <- NewProdPop %>% filter(genoA == "a/a" & genoB == "b/b" &  sex == "F") %>% top_frac(0.2, merit) ### higher retention so that there are enough passed down for BW females
      NewProd_Females <- union(NewProd_Females, NewProd_Females1) %>% distinct()
      
      NewProd_Males <- NewProdPop %>% filter(sex == "M") %>% top_frac(0.05, merit) 
      NewProd_Males1 <- NewProdPop %>% filter(genoA == "a/a" & genoB == "b/b" &  sex == "F") %>% top_frac(0.05, merit) ### higher retention so that there are enough passed down for BW females
      NewProd_Males <- union(NewProd_Males, NewProd_Males1) %>% distinct()
      
      ############################### CHECK UNION FUNCTIONS #################
      
      ProdPop <- rbind.fill(ProdPop, NewProd_Females, NewProd_Males) 
      
      if (g == 1) { 
        ProdPopAll <- data.frame(ProdPop)
      } else  (ProdPopAll <- rbind.fill(ProdPopAll, ProdPop))
      
    }
    
    if (g >= 1){
      
      ProdPop <- anti_join(ProdPop, Prod_Females, by = "ID") ## removes pigs bred in ProdPop to prevent from being bred again in same generation 
      
      Prod_MultPop_Females <- ProdPop %>% filter(sex == "F" & herd == "A" | herd == "B") %>% filter(age >= AgeFirstMate & age %% FarrowInt == rem) %>% top_frac(0.5, merit)
      ProdPop <- anti_join(ProdPop, Prod_MultPop_Females, by = "ID") ## removes pigs transferred down to multpop from ProdPop permanently
      
      #no selection used on males as hard selection in SPFpop drives resistance drift
      SPF_MultPop_Males <- SPFpop %>% filter(sex == "M" & herd == "B") %>% filter(age >= AgeFirstMate) #%>% top_frac(0.1, merit) 
      SPF_MultPop_Males <- BreedSelection_frac(SPF_MultPop_Males, 0.25)
      
      SPFpop <-  anti_join(SPFpop, SPF_MultPop_Males, by = "ID") ## removes MultBoars from SPFpop 
      
      MultPop <- rbind.fill(MultPop, Prod_MultPop_Females, SPF_MultPop_Males) %>% mutate(ID = as.character(ID)) #puts new Multpop with SPFpop & ProdPop. Boars are moved as not AI
      
     # if (nrow(MultPop %>% filter(sex == "F") %>% filter (age >= AgeFirstMate & age %% FarrowInt == rem)) >5000) {
    #    Mult_Females <- MultPop %>% filter(sex == "F") %>% filter (age >= AgeFirstMate & age %% FarrowInt == rem)  %>% top_n(5000, merit)  }
    #  else (Mult_Females <- MultPop %>% filter(sex == "F") %>% filter (age >= AgeFirstMate & age %% FarrowInt == rem)  %>% top_n(0.5, merit))
      
      ############ SORT THIS SELECTION FOR MULTS ############
      
      
      Mult_Males <- MultPop %>% filter(sex == "M") %>% filter(age >= AgeFirstMate) # %>% top_frac(0.1, merit) #selection performed below 
      Mult_Males <- BreedSelection_n (Mult_Males, 200) ### select boars on known genotype
  
      Mult_Females <- MultPop %>% filter(sex == "F") %>% filter(age >= AgeFirstMate & age %% FarrowInt == rem) %>% top_n(8000, merit) %>% na.omit #selection performed below 
     # Mult_Females <- top_n(Mult_Females, 8000, merit)  ### select sows on pedigree merit
      
      # Mult_Females <- MultPop %>% filter(sex == "F") %>% filter (age >= AgeFirstMate & age %% FarrowInt == rem) %>% top_frac(0.5, merit) ## probably best to filter for age here, not realistic to redo it for each cycle ##
      
      NewMultPop <- CreatePiglets(Mult_Males, Mult_Females, indexSD, g, paste0("Mult",g,"_"), littersize)
      
      NewMult_Females <- NewMultPop %>% filter(sex == "F") %>% top_n(8000, merit) ## takes the top 20% of new females created, all that is required. #### increase if I want more PN breeding ###
      #  NewMult_Females <- rbind.fill(NewMult_Females, (filter(NewMultPop, sex == "F" & genoA =="a/a" & genoB == "b/b"))) %>% top_n(4000, merit) %>% distinct()
      
      #NewMult_Males <- rbind(NewMultPop %>% filter(sex == "M" & genoA =="a/a" & genoB == "b/b") %>% top_n(400, merit), NewMultPop %>% filter(sex == "M") %>% top_n(400, merit)) %>% distinct()
      
      
      MultPop <- rbind.fill(MultPop, NewMult_Females) %>% mutate(ID = as.character(ID)) %>% distinct()
      
      if (g == 1) { 
        MultPopAll <- data.frame(MultPop)
      } else  (MultPopAll <- rbind.fill(MultPopAll, MultPop))
      
    } 
    
    ###############################
    
    if (g >= 1){
      
      MultPop <-  anti_join(MultPop, Mult_Females, by = "ID") #### keep MultPop females that have bred out of potential BW pop. rejoin later
      
      Mult_BW_Fem <- MultPop %>% filter(sex == "F") %>% filter(age >= AgeFirstMate & age %% FarrowInt == rem) #%>% top_frac(0.7, merit) 
      MultPop <- anti_join(MultPop, Mult_BW_Fem, by = "ID") ## removes pigs transferred down to BWpop from MultPop permanently
      
      SPF_BWpop_Males <- SPFpop %>% filter(sex == "M" & herd == "T") %>% filter(age >= AgeFirstMate) 
      SPF_BWpop_Males <- BreedSelection_frac(SPF_BWpop_Males, 0.2)
      
      ####### CHECK ENOUGH MALES #########
      
      SPFpop <-  anti_join(SPFpop, SPF_BWpop_Males, by = "ID") ##no returning pigs as not an AI program
      
      BWpop <- rbind.fill(BWpop, Mult_BW_Fem, SPF_BWpop_Males) ## put MultPop females & SPFpopT into BW population
      
      BW_Fem_Breed <- BWpop %>% filter(sex == "F") %>% filter(age >= AgeFirstMate & age %% FarrowInt == rem) %>% top_n(20000, merit)

      BW_Males <- BWpop %>% filter(sex == "M") %>% filter(age >= AgeFirstMate) %>% BreedSelection_n(2100) %>% na.omit () ## merit selection on males put into BW pop initially
      
      CommercialPop <- CreatePiglets(BW_Males, BW_Fem_Breed, indexSD, g, paste0("BW",g,"_"), littersize)  
      
      # NewBW_Females <- CommercialPop %>% filter(sex == "F" & genoA == "a/a" & genoB == "b/b") %>% top_frac(0.2, merit) 
      # CommercialPop <-  anti_join(CommercialPop, NewBW_Females, by = "ID") ## new breeders aren't for commercial sale
      
      #  BWpop <- rbind.fill(BWpop, NewBW_Females)
      
      if (g == 1) { 
        BWpopAll <- data.frame(BWpop)
      } else  (BWpopAll <- rbind.fill(BWpopAll, BWpop))
      
      
      if (g == 1) { 
        CommercialPopAll <- data.frame(CommercialPop)
      } else  (CommercialPopAll <- rbind.fill(CommercialPopAll, CommercialPop))  
      
    }
    
    ##################################
    ########## END OF BREEDINGS ##########
    
  #  SPFpop <- select(SPFpop, -X)
   # ProdPop <- select(ProdPop, -X)
  #  MultPop <- select(MultPop, -X)
  #  BWpop <- select(BWpop, -X)
    
        #####################
    
    SPFpop <- rbind.fill(SPFpop, SPF_Breeders, SPFNucA_Male, SPFNucA_Fem, SPFNucB_Male, SPFNucB_Fem, SPFNucT_Male, SPFNucT_Fem) #%>% distinct() 
    ## All SPF pigs. SPF pigs moved to another tier are already excluded by anti_join from SPF tables
    
    if (sum(SPFpop$age > 8) > 10000) {
      
          NextBreeders <- SPFpop %>% filter (sex =="F" & age > 9 & age %% FarrowInt == 2) ### filters all pigs that will breed next loop to be included. 
      
      #### removing females with neither allele for resistance from herd. ### same as numbers for initial basepop
      SPFpopA_females <- SPFpop %>% filter(sex == "F" & herd == "A") %>% filter(genoA != "A/A" & genoB != "B/B")
      SPFpopA_females <- GestationCull(SPFpopA_females, 650)
      SPFpopB_females <- SPFpop %>% filter(sex == "F" & herd == "B")  %>% filter(genoA != "A/A" & genoB != "B/B")
      SPFpopB_females <- GestationCull(SPFpopB_females, 325)
      SPFpopT_females <- SPFpop %>% filter(sex == "F" & herd == "T") %>% filter(genoA != "A/A" & genoB != "B/B")
      SPFpopT_females <- GestationCull(SPFpopT_females, 500)
      
      
      SPFpop_males <- SPFpop %>% filter(sex == "M") %>% filter(age >= 8)  %>% top_n(100, merit) ### select top merit sires
      SPFA_males <- SPFpop %>% filter(sex == "M" & herd == "A") %>% filter(age >= 8) %>% filter(genoA != "A/A" & genoB != "B/B") %>% top_n(100, merit) 
      SPFB_males <- SPFpop %>% filter(sex == "M" & herd == "B") %>% filter(age >= 8) %>% filter(genoA != "A/A" & genoB != "B/B") %>% top_n(200, merit) 
      SPFT_males <- SPFpop %>% filter(sex == "M" & herd == "T") %>% filter(age >= 8) %>% filter(genoA != "A/A" & genoB != "B/B") %>% top_n(1000, merit) 
      
      SPFpop_males <- rbind.fill(SPFpop_males, SPFA_males, SPFB_males, SPFT_males)  %>% distinct ()
      SPFA_males <- NULL
      SPFB_males <- NULL
      SPFT_males <- NULL
      
      SPFpopA_piglets <- SPFpop %>% filter(herd == "A" & sex =="M") %>% filter(age == 1) %>% filter(genoA != "A/A" & genoB != "B/B") %>% top_n(1000, merit) 
      SPFpopB_piglets <- SPFpop %>% filter(herd == "B" & sex =="M") %>% filter(age == 1) %>% filter(genoA != "A/A" & genoB != "B/B") %>% top_n(1000, merit)
      SPFpopT_piglets <- SPFpop %>% filter(herd == "T" & sex =="M") %>% filter(age == 1) %>% filter(genoA != "A/A" & genoB != "B/B") %>% top_n(1000, merit) 
      ### careful that older pigs are not killed as piglets will be higher merit but can't breed/ put in selection for if over 16 months???
      ### must be 1 to cull. allows for birth and genomic/pedigree selection
      
      topSPFpop <-  rbind.fill(NextBreeders, SPFpopA_females, SPFpopB_females, SPFpopT_females, SPFpop_males, SPFpopA_piglets, SPFpopB_piglets, SPFpopT_piglets) 
      
      SPFpop <- semi_join(topSPFpop, SPFpop, by = "ID") %>% distinct() %>% mutate(ID = as.character(ID)) ### only topSPFpop remain as SPFpop
      
      SPFpopA_females <- NULL ### remove tables to prevent accumulation of data slowing code
      SPFpopB_females <- NULL
      SPFpopT_females <- NULL
      SPFpopA_males <- NULL
      SPFpopB_males <- NULL
      SPFpopT_males <- NULL
      SPFpopA_piglets <- NULL
      SPFpopB_piglets <- NULL
      SPFpopT_piglets <- NULL
      topSPFpop <- NULL 
      SPF_Breeders <- NULL 
    }
    
    SPFpop <- data.frame(ageing(SPFpop))  
    
    print(paste0("SPF Males:", sum(SPFpop$sex == "M"), sep = " "))  #### could be worth changing these to age > age first mate to see breeding animals???
    print(paste0 ("SPF Females:", sum(SPFpop$sex =="F"), sep = " "))
    
    print(paste0 ("SPFA_Resistance:", round(nrow(filter(SPFpop, herd == "A" & genoA == "a/a" & genoB =="b/b")) / nrow(filter(SPFpop, herd == "A")) *100), "%"))
    print(paste0 ("SPFB_Resistance:", round(nrow(filter(SPFpop, herd == "B" & genoA == "a/a" & genoB =="b/b")) / nrow(filter(SPFpop, herd == "B"))*100), "%"))
    print(paste0 ("SPFT_Resistance:", round(nrow(filter(SPFpop, herd == "T" & genoA == "a/a" & genoB =="b/b")) / nrow(filter(SPFpop, herd == "T")) *100), "%"))
    
    ########################
    
    ProdPop <- rbind.fill(ProdPop, Prod_Females) %>% distinct() 
    
    if (sum(ProdPop$age > 8) > 15000){
      
      NextBreedersProd <- ProdPop %>% filter (sex =="F" & age > 9 & age %% FarrowInt == 2)
      
      ProdPopFem <- ProdPop %>% filter(sex == "F") %>% filter(age >= AgeFirstMate)  %>% filter(genoA != "A/A" & genoB != "B/B") 
      ProdPopFem <- GestationCull(ProdPopFem, 1000)
      
      ProdPopMales <- ProdPop %>% filter (sex == "M") %>% filter(age > AgeFirstMate) %>% filter(genoA != "A/A" & genoB != "B/B") %>% top_n(800, merit)
      ProdPopPiglets <- ProdPop %>% filter(sex == "F") %>% filter(age < AgeFirstMate & age >= 1) %>% filter(genoA != "A/A" & genoB != "B/B") %>% top_n(15000, merit) 
      ProdPop <- rbind.fill(ProdPopFem, ProdPopMales, ProdPopPiglets, NextBreedersProd) 
    }
    
    ProdPop <- data.frame(ageing(ProdPop)) 
    
    print(paste0("Prod Males:", sum(ProdPop$sex == "M"), sep = " "))
    print(paste0 ("Prod Females:", sum(ProdPop$sex =="F"), sep = " "))
    
    print(paste0 ("ProdPop:", round(nrow(filter(ProdPop, genoA == "a/a" & genoB =="b/b")) / nrow(filter(ProdPop)) *100), "%"))
    
    ###################
    
    MultPop <- rbind.fill(Mult_Females, MultPop) %>% distinct() 
    
    if (sum(MultPop$age > 8) > 60000) {  ### may be too many!!!
      NextBreedersMult <- MultPop %>% filter (sex =="F" & age > 9 & age %% FarrowInt == 2)
      
      MultPopFem <- MultPop %>% filter(sex == "F") %>% filter(age >= AgeFirstMate) %>% top_n(60000, merit) #  %>% filter(genoA != "A/A") 
      MultPopMales <- MultPop %>% filter(sex == "M") %>% filter(age >= AgeFirstMate) %>% filter(genoA != "A/A" & genoB != "B/B")%>% top_n(1000, merit) # Always know geno of SPFpop
      MultPopPiglets <- MultPop %>% filter(sex == "F") %>% filter(age < AgeFirstMate & age >= 1) %>% filter(genoA != "A/A" & genoB != "B/B") %>% top_n(20000, merit) #piglets will always be hets as they are SPF bred
      MultPop <- rbind.fill(MultPopFem, MultPopMales, MultPopPiglets, NextBreedersMult) 
    }
    
    MultPop <- ageing(MultPop)
    
    print(paste0("Mult Males:", sum(MultPop$sex == "M"), sep = " "))
    print(paste0 ("Mult Females:", sum(MultPop$sex =="F"), sep = " "))
    
    print(paste0 ("MultPop:", round(nrow(filter(MultPop, genoA == "a/a" & genoB =="b/b")) / nrow(filter(MultPop)) *100), "%"))
    
    ###################
  
    if (sum(BWpop$age > 8) > 120000) {  
      
      BWpopFem <- BWpop %>% filter(sex == "F") %>% filter(age >= AgeFirstMate) %>% top_n(120000, merit) 
      
      BWpopMales <- BWpop %>% filter(sex == "M") %>% filter(age >= AgeFirstMate) %>% filter(genoA != "A/A" & genoA != "B/B") %>% top_n(10000, merit) 
      BWpopPiglets <- BWpop %>% filter(sex == "F") %>% filter(age < AgeFirstMate & age >= 1) %>% filter(genoA != "A/A"  & genoA != "B/B") %>% top_n(20000, merit) ##always bred with SPF by the time selection culls
      BWpop <- rbind.fill(BWpopFem, BWpopMales, BWpopPiglets) 
    }
    
    BWpop <- ageing(BWpop)
    
    print(paste0("BW Males:", sum(BWpop$sex == "M"), sep = " "))
    print(paste0 ("BW Females:", sum(BWpop$sex =="F"), sep = " "))
    
    print(paste0 ("BWpop:", round(nrow(filter(BWpop, genoA == "a/a" & genoB =="b/b")) / nrow(filter(BWpop)) *100), "%"))
    
    print(paste0 ("Commercial Pigs:", nrow(CommercialPop), sep = " ")) ## need a table binding all commercial piglets to see value of IAV to farmers
    print(paste0 ("Commercial Pigs:", round(nrow(filter(CommercialPop, genoA == "a/a" & genoB =="b/b")) / nrow(filter(CommercialPop)) *100), "%"))
    
    
    
    AttemptedAllEdits <- A_AttemptedAllEdits %>% left_join(B_AttemptedAllEdits, by = "gen") %>% left_join(T_AttemptedAllEdits, by = "gen")
    
    
    #CommercialPop <- select(CommercialPop, -X)
    
    
  } ### end of g loop
  
  
  OutputData_SPF <- function (popdata, label){
    
    
    MeritAve <- function (popdata) {popdata %>% filter(gen > 0) %>% group_by(gen) %>% summarise (MeanMerit = mean(merit)) }
    
    PropResistant <-  function (popdata) {
      popdata %>% filter (gen > 0) %>%
        group_by(gen, IAV) %>%
        summarise (ResistantCount = n()) %>%
        mutate(prop = prop.table(ResistantCount) *100) %>% 
        filter(IAV == "0") %>% select(gen, ResistantCount, prop)} #### needs to be proportion of the total population really???
    
    PopCount <- function(popdata) {popdata %>% filter(gen > 0) %>% group_by(gen) %>% summarise (PopCount = n())}
    
    MeritAveTab <- MeritAve(popdata) 
    PropResistantTab <- PropResistant(popdata)
    PopCountTab <- PopCount(popdata)
    
    SumStats <- (data.frame(matrix(nrow = 121, ncol = 1))) 
    colnames(SumStats) <- c("gen") 
    
    SumStats$gen <- seq(1,121)
    
    SumStats <- left_join(SumStats, MeritAveTab, by = "gen", all.x = TRUE) %>%
      left_join(PropResistantTab, by = "gen", all.x = TRUE) %>% 
      left_join(PopCountTab, by = "gen", all.x = TRUE) %>%
      left_join(AttemptedAllEdits, by = "gen", all.x= TRUE)
    
    colnames(SumStats) <- paste(label, colnames(SumStats), sep = "_")
    return (SumStats)
  }
  
  OutputData <- function (popdata, label){
    
    
    MeritAve <- function (popdata) {popdata %>% filter(gen > 0) %>% group_by(gen) %>% summarise (MeanMerit = mean(merit)) }
    
    PropResistant <-  function (popdata) {
      popdata %>% filter (gen > 0) %>%
        group_by(gen, IAV) %>%
        summarise (ResistantCount = n()) %>%
        mutate(prop = prop.table(ResistantCount) *100) %>% 
        filter(IAV == "0") %>% select(gen, ResistantCount, prop)} #### needs to be proportion of the total population really???
    
    PopCount <- function(popdata) {popdata %>% filter(gen > 0) %>% group_by(gen) %>% summarise (PopCount = n())}
    
    MeritAveTab <- MeritAve(popdata) 
    PropResistantTab <- PropResistant(popdata)
    PopCountTab <- PopCount(popdata)
    
    SumStats <- (data.frame(matrix(nrow = 121, ncol = 1))) 
    colnames(SumStats) <- c("gen") 
    
    SumStats$gen <- seq(1,121)
    
    SumStats <- left_join(SumStats, MeritAveTab, by = "gen", all.x = TRUE) %>%
      left_join(PropResistantTab, by = "gen", all.x = TRUE) %>% 
      left_join(PopCountTab, by = "gen", all.x = TRUE) 
    
    colnames(SumStats) <- paste(label, colnames(SumStats), sep = "_")
    return (SumStats)
  }
  
  SPFpopAllOutput <- OutputData_SPF(SPFpopAll, "SPF")
  ProdPopAllOutput <- OutputData(ProdPopAll, "Prod")
  MultPopAllOutput <- OutputData(MultPopAll, "Mult")
  BWpopAllOutput <- OutputData(BWpopAll, "BW")
  CommercialPopAllOutput <- OutputData(CommercialPopAll, "Comm")
  
  OutputFile <- cbind(SPFpopAllOutput, ProdPopAllOutput, MultPopAllOutput, BWpopAllOutput, CommercialPopAllOutput)
  
  write.csv(OutputFile, paste0("Trial_",i,".csv")) 
  
  print(Sys.time())
  
} #### end of i loop

