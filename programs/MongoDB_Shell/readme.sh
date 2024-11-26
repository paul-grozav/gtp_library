# See latest version here:
# https://www.mongodb.com/try/download/shell
version="2.3.3" &&
folder_name="mongosh-${version}-linux-x64" &&
file_name="${folder_name}.tgz" &&
wget "https://downloads.mongodb.com/compass/${file_name}" &&
tar xvf ${file_name} &&
rm ${file_name} &&
mv ${folder_name} ${version} &&
rm -rf latest &&
ln -s ${version} latest &&
true
