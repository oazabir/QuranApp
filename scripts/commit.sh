cd ~/QuranApp
git pull
scripts/generateoffline.sh
git add -A
git commit -m "$1"
git push
ssh -t root@23.227.163.239 "./quranapp.sh"
