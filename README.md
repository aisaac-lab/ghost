```Gemfile
gem 'maxwell', github: 'aisaac-lab/maxwell'
```

```bash
export URL=http://zproxy.lum-superproxy.io:22225
export USER=lum-customer-hl_4539b278-zone-zone3
export PASS=20kdmhrmhen6

bundle exec rspec
```


```rb
puts User.where('? < last_access_at', 1.month.ago).group(:last_user_agent).count.reject { |k, _| k.match?(/CFNetwork/) || k.match?(/okhttp/) }.inspect
```