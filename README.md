AliyunIot
======

AliyunIot gem 可以帮助开发者方便地在Rails环境中使用[阿里云物联网套件](https://help.aliyun.com/product/30520.html)提供的服务，包括

- [服务器端API](https://help.aliyun.com/document_detail/30557.html)
- [消息服务](https://help.aliyun.com/product/27412.html)

## 安装

使用 `gem install`

```
gem install "aliyun_iot"
```

或者添加下面这行到 `Gemfile`:

```
gem 'aliyun_iot'
```

运行下面这行代码来安装:

```console
bundle install
```

运行下面这行代码来生成配置文件:

```console
rails g aliyun_iot:install
```

## 配置

#### Rails 全局配置
Rails应用程序中，需要将配置文件放在`config/aliyun_iot.yml`，可以为不同environment创建不同的配置。

```yml
development:
   access_key_id:       access_key_id
   access_key_secret:   access_key_secret
   end_point:           http(s)://{AccountId}.mns.cn-shanghai.aliyuncs.com
   product_key:         product_key
   base_url:            iot.cn-shanghai.aliyuncs.com

production:
   access_key_id:       access_key_id
   access_key_secret:   access_key_secret
   end_point:           http(s)://{AccountId}.mns.cn-shanghai.aliyuncs.com
   product_key:         product_key
   base_url:            iot.cn-shanghai.aliyuncs.com
```

## 命令

#### Queue

```ruby
  AliyunIot::Queue.queues                                                ## 列出所有队列
  AliyunIot::Queue[QueueName].receive_message(WaitSeconds)               ## 消费消息
  AliyunIot::Queue[QueueName].batch_receive_message(MessageCount, WaitSeconds)  ## 批量消费消息
  AliyunIot::Queue[QueueName].peek                                       ## 查看消息
  AliyunIot::Queue[QueueName].create({DelaySeconds, MaximumMessageSize, MessageRetentionPeriod, VisibilityTimeout, PollingWaitSeconds, LoggingEnabled})                                   ## 创建队列
  AliyunIot::Queue[QueueName].delete                                     ## 删除队列
  AliyunIot::Queue[QueueName].send_message({MessageBody, DelaySeconds, Priority})  ## 发送消息
```

#### Topic

```ruby
  AliyunIot::Topic.topics                                                ## 列出所有主题
  AliyunIot::Topic[TopicName].create({MaximumMessageSize, LoggingEnabled}) ## 创建主题
  AliyunIot::Topic[TopicName].delete                                     ## 删除主题
  AliyunIot::Topic[TopicName].get_topic_attributes                       ## 获取主题属性
  AliyunIot::Topic[TopicName].subscribe({Endpoint, FilterTag, NotifyStrategy, NotifyContentFormat}) ## 订阅主题
  AliyunIot::Topic[TopicName, SubscriptionName].unsubscribe              ## 取消订阅
  AliyunIot::Topic[TopicName].publish_message({MessageBody, MessageTag, MessageAttributes}) ## 向指定主题发布消息
```

#### Product

```ruby
  AliyunIot::Product.create(Name)                                        ## 创建产品
  AliyunIot::Product.batch_get_device_state({DeviceName.1, DeviceName.2 ....})   ## 批量查询设备状态
  AliyunIot::Product.check_regist_state(ApplyId)                         ## 查询注册状态
  AliyunIot::Product.list_regist_info(ApplyId, PageSize, CurrentPage)    ## 批量查询注册状态
  AliyunIot::Product[ProductKey].update({ProductName, ProductDesc})      ## 修改产品信息
  AliyunIot::Product[ProductKey].list({PageSize, CurrentPage})           ## 查询产品的设备列表
  AliyunIot::Product[ProductKey].regist_device({DeviceName})             ## 设备注册
  AliyunIot::Product[ProductKey].regist_devices({DeviceName.1, DeviceName.2 ....})    ## 批量注册设备
  AliyunIot::Product[ProductKey].pub({TopicFullName, MessageContent})    ## 发布消息到设备
  AliyunIot::Product[ProductKey].rrpc({DeviceName, RequestBase64Byte, Timeout}) ## 发消息给设备并同步返回响应
```

#### Message

由 AliyunIot::Queue[QueueName].receive_message 接口获取的消息，在消费后需要及时删除
```ruby
  AliyunIot::Queue[QueueName].receive_message(3).delete
```
