#!/bin/bash
etcd --listen-client-urls=http://0.0.0.0:2379 --advertise-client-urls=http://0.0.0.0:2379 &
etcdctl mkdir _hidden
etcdctl mkdir visible
etcdctl mkdir visible/_hiddensubdir
etcdctl mkdir visible/visiblesubdir
etcdctl mkdir _hidden/_hiddensubdir
etcdctl mkdir _hidden/visiblesubdir
etcdctl mk visroottext "test text"
etcdctl mk _hiddenroottext "test text"
etcdctl mk _hidden/vistext "test text"
etcdctl mk _hidden/_hiddentext "test text"
etcdctl mk visible/vistext "test text"
etcdctl mk visible/_hiddentext "test text"
etcdctl mk visible/_hiddensubdir/vistext "test text"
etcdctl mk visible/_hiddensubdir/_hiddentext "test text"
etcdctl mk visible/visiblesubdir/vistext "test text"
etcdctl mk visible/visiblesubdir/_hiddentext "test text"
etcdctl mk _hidden/_hiddensubdir/vistext "test text"
etcdctl mk _hidden/_hiddensubdir/_hiddentext "test text"
etcdctl mk _hidden/visiblesubdir/vistext "test text"
etcdctl mk _hidden/visiblesubdir/_hiddentext "test text"
etcdctl mk visrootbinfile < /bin/sh
etcdctl mk _hiddenrootbinfile < /bin/sh
etcdctl mk _hidden/visbinfile < /bin/sh
etcdctl mk _hidden/_hiddenbinfile < /bin/sh
etcdctl mk visible/visbinfile < /bin/sh
etcdctl mk visible/_hiddenbinfile < /bin/sh
etcdctl mk visible/_hiddensubdir/visbinfile < /bin/sh
etcdctl mk visible/_hiddensubdir/_hiddenbinfile < /bin/sh
etcdctl mk visible/visiblesubdir/visbinfile < /bin/sh
etcdctl mk visible/visiblesubdir/_hiddenbinfile < /bin/sh
etcdctl mk _hidden/_hiddensubdir/visbinfile < /bin/sh
etcdctl mk _hidden/_hiddensubdir/_hiddenbinfile < /bin/sh
etcdctl mk _hidden/visiblesubdir/visbinfile < /bin/sh
etcdctl mk _hidden/visiblesubdir/_hiddenbinfile < /bin/sh
etcdctl mk visrootfile < /etc/passwd
etcdctl mk _hiddenrootfile < /etc/passwd
etcdctl mk _hidden/visfile < /etc/passwd
etcdctl mk _hidden/_hiddenfile < /etc/passwd
etcdctl mk visible/visfile < /etc/passwd
etcdctl mk visible/_hiddenfile < /etc/passwd
etcdctl mk visible/_hiddensubdir/visfile < /etc/passwd
etcdctl mk visible/_hiddensubdir/_hiddenfile < /etc/passwd
etcdctl mk visible/visiblesubdir/visfile < /etc/passwd
etcdctl mk visible/visiblesubdir/_hiddenfile < /etc/passwd
etcdctl mk _hidden/_hiddensubdir/visfile < /etc/passwd
etcdctl mk _hidden/_hiddensubdir/_hiddenfile < /etc/passwd
etcdctl mk _hidden/visiblesubdir/visfile < /etc/passwd
etcdctl mk _hidden/visiblesubdir/_hiddenfile < /etc/passwd

#etcd RBAC settings
etcdctl user add root:toor
etcdctl auth enable
etcdctl -u root:toor role revoke guest --readwrite --path '/*'
etcdctl -u root:toor role grant guest --path '/_hidden' -read

#etcd with ssl
etcd --cert-file certificate.pem --key-file key.pem --listen-client-urls=https://0.0.0.0:2379 --advertise-client-urls=https://0.0.0.0:2379

#etcd cert-based auth
etcd --trusted-ca-file=/etc/ssl/etcd/ca.crt --client-cert-auth=true --cert-file certificate.pem --key-file key.pem --listen-client-urls=https://0.0.0.0:2379 --advertise-client-urls=https://0.0.0.0:2379