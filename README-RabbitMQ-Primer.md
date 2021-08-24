# RabbitMQ Primer

## Summary

This document covers some basic concepts about RabbitMQ.

## Quick Start

Once you have a RabbitMQ host up, you can connect to the management console via https://localhost:15671/. You might have
to accept your browser's security warning if you are using a self-signed TLS certificate.

From the RabbitMQ management console you can:

* See the status of the server, including resource usage.
* Create exchanges, queues and bindings.
* Publish messages into any exchange or queue.
* Consume messages from any queue.
* And more...

## What is RabbitMQ?

RabbitMQ is an application message broker typically used in applications that rely on message patterns (applications that send messages to each other). Message brokers are sometimes also referred to as message bus, or even enterprise message bus. 

Extensive documentation is available on the [RabbitMQ Documentation page](https://www.rabbitmq.com/documentation.html). This README is not intended to replace the extensive documentation on that site, but instead provides a quick primer.

### AMQP Protocol

RabbitMQ is primarily based on the **AMQP Protocol** where messages are published into an **Exchange** and where consumers subscribe to **Queues** that are bound to **Exchanges**. 

A message is typically text in any format as defined by the publishers/consumers of your application. RabbitMQ does not enforce any structure or syntax inside a message body, though there is some structure around message headers (and is a topic )

RabbitMQ supports several kinds of Exchnages that provide different features.

| Exchange type   | Default pre-declared names    |
| --------------- | ----------------------------- |
| Direct exchange | (Empty string) and amq.direct |
| Fanout exchange | amq.fanout                    |
| Topic exchange  | amq.topic                     |

By default, RabbitMQ starts out with the above default exchanges (one for each supported type), but an admin user (or application with admin permission) can create as many exchanges as needed for an application. Multiple **Direct**, **Fanout** and **Topic** exchanges are possible.

RabbitMQ supports a number of useful patterns.

* work queues (a.k.a. competing consumer) - in this pattern messages are published to a **direct exchange** named by the publisher, which is bound to a queue. Messages wait in the queue until a consumer establishes a connection to the queue at which time the broker delivers each message to a single consumer. The broker expects acknowledgment by each consumer signifying both receipt and proper handling of a message. This pattern supports re-queue on both consumer **NACK** and consumer timeout. If no consumers are connected to the target queue, the messages will be accumulated by the broker and delivered in the future to consumers that connect.
  * This pattern is supported over RabbitMQ's AMQP, STOMP and Web STOMP protocols. This pattern is not supported over MQTT nor Web MQTT.
  * This pattern is desirable in guaranteed message applications where a message must be handled by a single consumer or else re-queued.
* fanout - in this pattern messages are published into a **fanout exchange** that is not bound to a specific queue. Instead, as consumers connect to the broker, each is assigned a transient queue (which can be named by the client for convenience and some persistence). Messages are delivered to all connected consumers as they arrive. If no consumers are connected, messages are not delivered and are simply silently dropped.
  * This pattern is supported over RabbitMQ's AMQP, STOMP, Web STOMP. This pattern is not supported over MQTT nor Web MQTT. 
  * This pattern is desirable in applications where guaranteed message delivery is not needed and where multiple subscribers are interested in a single message.
* topics (a.k.a. pub/sub with topics) - in this pattern messages are published into a **topic exchange** that is not bound to a specific queue. Instead, as subscribers connect to the broker, each is assigned a transient queue (which can be named by the client for convenience and some persistence). Messages are delivered to all connected subscribers as they arrive. If no subscribers are connected, messages are not delivered and are simply silently dropped. Subscribers can selectively receive messages by providing a **topic** to listen to.
  * This pattern is supported over RabbitMQ's AMQP, STOMP, Web STOMP, MQTT and Web MQTT protocols, though MQTT clients are limited to a single topic exchange shared among all MQTT messages.
  * This pattern is desirable in applications where guaranteed message delivery is not needed and where multiple subscribers are interested in a single message.
* routing (similar to work queues but introducing routing keys for message routing) - in this pattern messages are published to a **direct exchange** named by the publisher, which is bound to multiple queues based on the publisher's defined **routing key**. Once routed, messages wait in their destination queues until a consumer establishes a connection to the queue at which time the broker delivers each message to a single consumer. The broker expects acknowledgment by each consumer signifying both receipt and proper handling of a message. This pattern supports re-queue on both consumer **NACK** and consumer timeout. If no consumers are connected to a destination queue, the messages will be accumulated by the broker and delivered in the future to consumers that connect.
  * This pattern is supported using RabbitMQ's AMQP, STOMP and Web STOMP protocols. This pattern is not supported over MQTT nor Web MQTT. 
  * This pattern is desirable in guaranteed message applications where a message must be handled by a single consumer or else re-queued but where certain messages (based on **routing key**) should be sent to different queues. 
* RPC - in this pattern, similar to a work queue, a consumer is delivered a message and is also expected to reply with some response. The broker handles the logistics of connecting the publisher and consumer using transient queues. We won't cover this pattern here as it is considered an anti-pattern in messaging systems. Why? HTTP Rest is a much better solution to connect two systems together in a real-time fashion.

All the patterns are discussed in the [RabbitMQ Tutorials page](https://www.rabbitmq.com/getstarted.html) including rich examples in many languages.

The **AMQP Protocol** implements an important feature to __guaranteed message handling__. In particular, RabbitMQ uses a concept of **ACK/NACK** to allow a consumer of a message to acknowledge to the broker that a message has been handled. When a consumer fails to **ACK** a message in a certain amount of time, the broker can take action on that message to ensure a different consumer handles the message or can even send the message to a **Dead Letter Exchange** where an application's developers can figure out what went wrong.

The **AMQP protocol** as implemented by RabbitMQ is described in [AMQP 0-9-1 Model Explained](https://www.rabbitmq.com/tutorials/amqp-concepts.html).

### Other Protocols

In addition to the **AMQP Protocol**, RabbitMQ also supports several other protocols by using plugins supported by the core project. Of interest to us are:

* MQTT - "... was designed as an extremely lightweight publish/subscribe messaging transport. It is useful for connections with remote locations where a small code footprint is required and/or network bandwidth is at a premium." MQTT is fully described in https://mqtt.org/.
  * MQTT is implemented in RabbitMQ by routing all messages into a single **AMQP Topic Exchange**. The default exchange is **amq.topic** but this can be set to anything in the RabbitMQ configuration (though only a single topic exchange can be configured for MQTT.)
  * With this plugin enabled, MQTT clients see an MQTT standard server, while AMQP clients can choose to subscribe to the **AMQP Topic Exchange**. In both cases, clients then receive all or some messages based on a topic (as known in MQTT parlance) or routing key (as known in AMQP parlance). 
  * The MQTT protocol does not support the concept of __guaranteed message delivery__ (**ACK/NACK**) instead relying on a concept called **QOS**. RabbitMQ supports MQTT QOS0 (messages are delivered at most once) and MQTT QOS1 (messages are delivered at least once). RabbitMQ does not support MQTT QOS2 (messages are delivered exactly once.) 
  * Due to the lack of support for __guaranteed message delivery__, MQTT is not as desirable under RabbitMQ when an application requires that messages are absolutely handled by at least one recipient and where the application cannot tolerate duplicates easily.
  * RabbitMQ's implementation of MQTT is discussed on the [MQTT Plugin page](https://www.rabbitmq.com/mqtt.html).
* MQTT over Websockets (Web MQTT) - brings the support of the MQTT protocol to clients needing a websocket connection (HTML for example.)
  * Other than how clients connect to Web MQTT, this protocol is identical in features to MQTT.
  * RabbitMQ's implementation of Web MQTT is discussed on the [RabbitMQ Web MQTT Plugin](https://www.rabbitmq.com/web-mqtt.html).
* STOMP - RabbitMQ's documentation defines this protocol as "... a text-based messaging protocol emphasising (protocol) simplicity. It defines little in the way of messaging semantics...". Technically, the STOMP specification does not define specific destinations that a broker must implement, leaving it up to the implementation to decide this. 
  * RabbitMQ's implementation of STOMP allows clients to access any exchanges and queues configured on the broker. A default **Topic Exchange** can be configured but it not necessary if clients pass a complete topic semantic.
  * STOMP in RabbitMQ supports __guaranteed message handling__ (**ACK/NACK**) using client headers. It also supports a re-queue header in **NACK** so that the broker may re-queue failed messages. 
  * Due to STOMP's strong support for __guaranteed message handling__, it is the most desirable protocol to use in applications where messages must be handled without failure and where re-queuing of messages is desirable or even necessary.
  * RabbitMQ's implementation of STOMP is discussed on the [STOMP Plugin page](https://www.rabbitmq.com/stomp.html).
* STOMP over Websockets (Web STOMP) - brings the support of the STOMP protocol to clients needing a websocket connection (HTML for example.)
  * Other than how clients connect to Web STOMP, this protocol is identical in features to STOMP.
  * RabbitMQ's implementation of Web STOMP is discussed on the [RabbitMQ Web STOMP Plugin](https://www.rabbitmq.com/web-stomp.html).
  