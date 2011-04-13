use File::SharedNFSLock;
  my $flock = File::SharedNFSLock->new(
    file => 'some_file_on_nfs',
  );
  my $got_lock = $flock->lock(); # blocks for $timeout_acquire seconds if necessary
  if ($got_lock) {
    # hack hack hack...
  }
  $flock->unlock;
  
  # meanwhile, on another machine or in another process:
  my $flock = File::SharedNFSLock->new(
    file => 'some_file_on_nfs',
  );
  my $got_lock = $flock->lock(); # blocks for timeout or until first process is done
