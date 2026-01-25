Mydata <- read.csv(input_file) 

print("T检验结果")
result <- t.test( Mydata$Male, Mydata$Female, var.equal=FALSE )
print(result)