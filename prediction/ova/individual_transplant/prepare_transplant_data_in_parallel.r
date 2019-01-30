## name: prepare_transplant_data_in_parallel.r
## date: 10/10/2017

args <- commandArgs(trailingOnly = TRUE)
i=as.numeric(args[1])
num_parallel=as.numeric(args[2])

path0="../../../data/trimmed_set/";
path1="../../../data/normalization/normalize_by_sample_avg_sd/";
path2="../../../data/cv_set/";

# features
bf=as.matrix(read.delim(paste0(path1,"raw_breast_proteome.txt.scaled.avg_imputation.subset1.0"),check.names=F,row.names=1))
of=as.matrix(read.delim(paste0(path1,"raw_ova_proteome.txt.scaled.avg_imputation.subset1.0"),check.names=F,row.names=1))
ind_feature=intersect(rownames(of),rownames(bf)) # common feature gene
feature=cbind(of[ind_feature,],bf[ind_feature,])

# training data
bt=as.matrix(read.delim(paste0(path0,"breast_phospho.txt"),check.names=F,row.names=1))
ot=as.matrix(read.delim(paste0(path2,"train_ova_phospho_",i,".txt"),check.names=F,row.names=1))
ind_target=intersect(rownames(ot),rownames(bt)) # common target gene
train=cbind(ot[ind_target,],bt[ind_target,])

# test
test_all=as.matrix(read.delim(paste0(path2,"test_ova_phospho_",i,".txt"),check.names=F,row.names=1))
test=test_all[ind_target,]

feature_train=feature[,colnames(train)]
feature_test=feature[,colnames(test)]
# dim(train);dim(test);dim(feature_train);dim(feature_test)

writeLines(ind_target,con="common_target.txt")
write.table(feature_train,file="feature_train.dat",quote=F,sep="\t",na="NA",col.names=F,row.names=F)
write.table(feature_test,file="feature_test.dat",quote=F,sep="\t",na="NA",col.names=F,row.names=F)

# parallel
system(paste0("mkdir o",i))
system(paste0("cp fast_prediction.py o",i))
system(paste0("mv feature_*.dat o",i))

size_subset=ceiling(dim(train)[1]/num_parallel)
for(j in 1:num_parallel){
        first=(j-1)*size_subset+1
        last=j*size_subset
        if(last>dim(train)[1]) {last=dim(train)[1]}
        train_subset=train[first:last,]

        system(paste0("cp -r o",i," o",i,j))
        write.table(train_subset,file=paste0("o",i,j,"/train.dat"),quote=F,sep="\t",na="NA",col.names=F,row.names=F)
}



