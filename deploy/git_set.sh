cd ~/.ssh
mkdir key_backup
cp id_rsa* key_backup
rm id_rsa*
git config --global user.email "matthewxu@live.cn"
git config --global user.name "matthewxu"
ssh-keygen -t rsa -C "matthewxu@live.cn"

