This is a simple local HTTP repository to simplify Oracle Dockers image building by centralizing non-public software components.  
Before build the localrepo image put in this directory all Oracle installable components allowed to this private repo.  
For example:  
```bash
mochoa@localhost:~/jdeveloper/mywork/docker/localrepo$ ls -l
total 3805068
-rwxr-xr-x 1 mochoa mochoa         48 ago 12 10:23 buildDockerImage.sh
-rw-rw-r-- 1 mochoa mochoa        493 ago 15 18:19 Dockerfile
-rw-rw-r-- 1 mochoa mochoa  832500826 ago 15 18:01 fmw_12.2.1.1.0_wls_Disk1_1of1.zip
-rw-r--r-- 1 mochoa mochoa 1673544724 jul 16 19:19 linuxamd64_12102_database_1of2.zip
-rw-r--r-- 1 mochoa mochoa 1014530602 jul 16 19:20 linuxamd64_12102_database_2of2.zip
-rw-rw-r-- 1 mochoa mochoa  315891481 jul 18 12:20 oracle-xe-11.2.0-1.0.x86_64.rpm.zip
-rwxr-xr-x 1 mochoa mochoa         97 ago 12 10:25 run-repo.sh
-rw-rw-r-- 1 mochoa mochoa   59874321 ago 15 17:32 server-jre-8u101-linux-x64.tar.gz
```
Finally edit Dockerfile with the images which will be include into the localrepo docker image.  
To build this image use:  
```bash
mochoa@localhost:~/jdeveloper/mywork/docker/localrepo$ ./buildDockerImage.sh
....
mochoa@localhost:~/jdeveloper/mywork/docker/localrepo$ $ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
localrepo           1.0.0               5a1fd9188df1        2 days ago          3.902 GB
```
To start using your local repo simple call:  
```bash
mochoa@localhost:~/jdeveloper/mywork/docker/localrepo$  ./run-repo.sh 
3801a62c652e990222dd6d8cab755e0d934130a2594ebc20c5c396cbcdc5fd37
Local repo is at: http://172.17.0.2:80/
```

