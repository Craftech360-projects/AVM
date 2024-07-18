// import 'package:AVMe/backend/storage/memories.dart'; // Adjust if necessary

// final MemoryStructured dummyStructuredMemory = MemoryStructured(
//   title: "Weekly Planning and Movie Night",
//   overview:
//       "Planned the upcoming week's tasks and scheduled a movie night with friends.",
//   emoji: "📅🎬",
//   category: "Personal",
//   actionItems: [
//     "Call mom on  ",
//     "Prepare presentation ",
//     "Go for a movie at ",
//   ],
//   pluginsResponse: [],
//   events: [
//     {
//       "title": "Go to 5th",
//       "description": "",
//       "startsAt": "2024-07-17T09:00:00",
//       "duration": 60
//     },
//     {
//       "title": "Watch a movie",
//       "description": "",
//       "startsAt": "2024-07-17T16:00:00",
//       "duration": 120
//     },
//     {
//       "title": "Shopping",
//       "description": "",
//       "startsAt": "2024-07-17T21:00:00",
//       "duration": 60
//     }
//   ],
// );

import 'package:AVMe/backend/storage/memories.dart'; // Adjust if necessary

final MemoryStructured dummyStructuredMemory = MemoryStructured(
  title: "Weekly Planning and Movie Night",
  overview:
      "Planned the upcoming week's tasks and scheduled a movie night with friends.",
  emoji: "📅🎬",
  category: "Personal",
  actionItems: [
    "Call mom on  ",
    "Prepare presentation ",
    "Go for a movie at ",
  ],
  pluginsResponse: [],
  events: [
    Event(
      "Go to 5th",
      DateTime.parse("2024-07-17T09:00:00"),
      60,
      description: "",
      created: false,
    ),
    Event(
      "Watch a movie",
      DateTime.parse("2024-07-17T16:00:00"),
      120,
      description: "",
      created: false,
    ),
    Event(
      "Shopping",
      DateTime.parse("2024-07-17T21:00:00"),
      60,
      description: "",
      created: false,
    ),
  ],
);
