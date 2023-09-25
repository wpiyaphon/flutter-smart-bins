
# Smart Bins

The project is a comprehensive application developed with Flutter, designed to showcase bin statuses, routes, and provide timely notifications to users. It achieves this by harnessing data transmitted from IoT devices through the capabilities of Firebase features.

## Features

- Bin Capacity Tracking <br />
Leveraging Firebase Real-Time Database, seamlessly update and present information can be delivered to users in real-time, ensuring that the latest data is consistently available and displayed to users.
- Shortest Distance Route <br />
This feature applies Directions API, offering application the ability to compute efficient routes by prioritizing factors such as travel time (as the primary consideration), distance, and the number of turns. However, customization is needed to get multiple routes.
- Notification <br />
Within Smart Bins application, Firebase Cloud Messaging seamlessly go through the process of registering a device to obtain its FCM token, enabling the application to effortlessly dispatch notifications through this unique identifier. Additionally, Firebase Functions gracefully operates as a dedicated 24/7 backend server, springing into action to trigger notification delivery when specific conditions are met.

## Authors

- [@wupiyaphon](https://www.github.com/wpiyaphon)

