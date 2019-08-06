# Extract the file names under one directory
File_Name_List <- list.files(path = "/Users/jerrypan/Desktop/GRIPS/Data/Citrobacter_Rodentium",
           full.names = TRUE, include.dirs = TRUE)
for (i in 1:length(File_Name_List)){
  write(File_Name_List[i], file = paste("/Users/jerrypan/Desktop/GRIPS/Data/Test_Index/", basename(File_Name_List[i]),"_basename"))
}
