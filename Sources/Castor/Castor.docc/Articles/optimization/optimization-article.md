# Optimization

@Metadata {
    @PageColor(purple)
    @PageImage(purpose: card, source: optimization-card, alt: "An image depicting a speedometer.")
}

Avoid wasting system resources unnecessarily.

## Overview

When your application integrates Google Cast through ``Castor``, resource usage must be carefully managed. Although player item itself is offloaded to the receiver device, the sender application still consumes system resources: it maintains a Cast session, communicates over the network, and updates the user interface in real time.

Poorly optimized usage can lead to unnecessary resource consumption or degraded user experience. For example, an application might start playback on the Cast receiver while also keeping local playback active, even though this scenario rarely makes sense and wastes CPU, memory, and battery.

By ensuring your application manages Cast sessions and interactions responsibly, you improve both performance and efficiency. Users benefit from smoother casting experiences, longer battery life, and reduced data usage.

This article discusses a few strategies to reduce resource consumption when using ``Castor`` in your application.

## Profile your application

"We should forget about small efficiencies, say about 97% of the time: premature optimization is the root of all evil. Yet we should not pass up our opportunities in that critical 3%."  
– Donald Knuth

Even though playback happens on the receiver device, the sender application should still be profiled to ensure efficient behavior. Use Instruments and system tools to identify optimization opportunities in the following areas:

- **Allocations Instrument:** Analyze memory usage to identify excessive consumption associated with your application process. You can filter allocations, such as with the keyword _player_, to pinpoint playback-related resources and verify that their count aligns with your expectations.
- **Time Profiler Instrument:** Detect unusual CPU activity and identify potential bottlenecks in your application's performance.
- **Network Instrument:** Useful to observe control message traffic when debugging. While network usage is minimal, monitoring it can help detect unexpected spikes in message frequency.
- **Activity Monitor Instrument:** Check your app's CPU and memory footprint while connected to a Cast session, ensuring resource usage remains stable.

## Limit metadata sent to the receiver

When sending media items to a Cast receiver, your application must provide metadata (such as title, description, and artwork). However, the Google Cast SDK imposes strict size limits on the messages exchanged between the sender and the receiver.

- **Avoid large payloads:** Long text, multiple high-resolution images, or excessive ``CastCustomData`` can exceed these limits and cause the load request to fail.
- **Prefer lightweight metadata:** Stick to the essentials (title, one or two images at reasonable resolution, and short description).
- **Store extra data on your server:** Instead of embedding large metadata directly in the Cast item, store it remotely and fetch it from the receiver app when needed.

By minimizing the metadata footprint, you ensure reliable communication with the receiver and reduce the risk of casting errors.

## Limit custom data payloads

``Castor`` provides the ``CastCustomData`` type to safely encode and decode application-specific metadata (e.g., chapters) exchanged between the sender and the receiver.

> Important: Keep the payload size small to avoid exceeding the [maximum transport message size](https://developers.google.com/cast/docs/media/messages) of **64 KB**.

Best practices:

- **Keep JSON simple:** Avoid deeply nested structures.
- **Be selective:** Only send the minimum information needed for the receiver to function.

By using ``CastCustomData`` wisely, you reduce risks of message rejection and ensure better compatibility with Google Cast limits.
