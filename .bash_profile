# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs
PATH=$PATH:$HOME/bin
PATH=$PATH:/sbin
PATH=$PATH:/usr/sbin
PATH=$PATH:/usr/local/sbin
PATH=$PATH:/usr/lib64/qt4/bin
PATH=$PATH:/usr/local/bin
PATH=$PATH:$HOME/go/bin
PATH=$PATH:/usr/local
export PATH

# anyenv
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"

# hadoop
export JAVA_HOME=/usr/java/default
export JAVA_HOME=/usr/java/default
export HADOOP_HOME=/usr/lib/hadoop
export HADOOP_NAMENODE_USER=hdfs
export HADOOP_DATANODE_USER=$HADOOP_NAMENODE_USER
export HADOOP_SECONDARYNAMENODE_USER=$HADOOP_NAMENODE_USER
export HADOOP_JOBTRACKER_USER=mapred
export HADOOP_TASKTRACKER_USER=$HADOOP_JOBTRACKER_USER
export HBASE_HOME=/usr/lib/hbase
export HIVE_HOME=/usr/lib/hive
export MAHOUT_HOME=/usr/lib/mahout
export SQOOP_HOME=/usr/lib/sqoop
export PATH=$PATH:.:$HADOOP_HOME/bin:$JAVA_HOME/bin:/usr/lib/cassandra-node1/bin

# vimrc
export MYVIMRC=~/.vimrc
