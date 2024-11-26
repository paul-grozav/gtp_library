version="2.0.1" &&
folder_name="mongocli_${version}_linux_x86_64" &&
file_name="${folder_name}.tar.gz" &&
wget "https://fastdl.mongodb.org/mongocli/${file_name}" &&
tar xvf ${file_name} &&
mv ${folder_name} ${version} &&
rm -rf latest &&
ln -s ${version} latest &&
true
