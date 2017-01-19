echo 'yes' | /root/redis-trib.rb create --replicas 1 \
`getent hosts redis-node1-svc | awk '{ print $1 }'`:7000 \
`getent hosts redis-node2-svc | awk '{ print $1 }'`:7000 \
`getent hosts redis-node3-svc | awk '{ print $1 }'`:7000 \
`getent hosts redis-node4-svc | awk '{ print $1 }'`:7000 \
`getent hosts redis-node5-svc | awk '{ print $1 }'`:7000 \
`getent hosts redis-node6-svc | awk '{ print $1 }'`:7000 \
`getent hosts redis-node6-svc | awk '{ print $1 }'`:7000

