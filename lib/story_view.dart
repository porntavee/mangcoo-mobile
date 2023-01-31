import 'package:wereward/shared/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class MoreStories extends StatefulWidget {
  MoreStories({Key key, this.model}) : super(key: key);

  final dynamic model;

  @override
  _MoreStoriesState createState() => _MoreStoriesState();
}

class _MoreStoriesState extends State<MoreStories> {
  final storyController = StoryController();
  int _currentPage = 0;
  PageController _pageController = PageController(
    initialPage: 0,
  );
  Future<dynamic> _futureModel;

  final theImage = Image.network(
      "https://images.unsplash.com/photo-1571260118569-c77a06a97a8c?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80",
      fit: BoxFit.cover);

  @override
  void initState() {
    _futureModel = postDio(
        '${partnerApi}read', {'limit': 100, 'category': widget.model['code']});
    super.initState();
  }

  /// Did Change Dependencies
  @override
  void didChangeDependencies() {
    // cache
    precacheImage(theImage.image, context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  List<dynamic> dataStories = [
    {
      'category': 'beauty',
      'imageUrlCreateBy':
          'https://pbs.twimg.com/profile_images/942755517390139392/wFwE6JDG_400x400.jpg',
      'createBy': 'admin 001',
      'data': [
        {
          'createBy': 'baifernbarr',
          'imageUrlCreateBy':
              'https://pbs.twimg.com/profile_images/942755517390139392/wFwE6JDG_400x400.jpg',
          'media': "text",
          'title': "I guess you'd love to see more of our food. That's great.",
          'caption': 'click!!',
          'linkUrl': "https://www.youtube.com/watch?v=2Tr1zbrY6y0",
        },
        {
          'createBy': 'baifern',
          'imageUrlCreateBy':
              'https://pbs.twimg.com/profile_images/942755517390139392/wFwE6JDG_400x400.jpg',
          'media': "image",
          'title': "I guess you'd love to see more of our food. That's great.",
          'mediaUrl':
              'https://cdnb.artstation.com/p/assets/images/images/005/152/717/large/nikita-kozlov-321.jpg?1488878116',
          'caption': 'click!!',
          'linkUrl': "https://www.youtube.com/watch?v=2Tr1zbrY6y0",
          'duration': 5
        },
        {
          'createBy': 'baifernbarr',
          'imageUrlCreateBy':
              'https://pbs.twimg.com/profile_images/942755517390139392/wFwE6JDG_400x400.jpg',
          'media': "video",
          'title': "I guess you'd love to see more of our food. That's great.",
          'mediaUrl':
              'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
          'caption': 'click!!',
          'linkUrl': "https://www.youtube.com/watch?v=2Tr1zbrY6y0",
          'duration': 120
        },
      ]
    },
    {
      'category': 'beauty',
      'imageUrlCreateBy':
          'https://pbs.twimg.com/profile_images/942755517390139392/wFwE6JDG_400x400.jpg',
      'createBy': 'admin 002',
      'data': [
        {
          'createBy': 'baifernbarr',
          'imageUrlCreateBy':
              'https://pbs.twimg.com/profile_images/942755517390139392/wFwE6JDG_400x400.jpg',
          'media': "text",
          'title': "I guess you'd love to see more of our food. That's great.",
          'caption': 'click!!',
          'linkUrl': "https://www.youtube.com/watch?v=2Tr1zbrY6y0",
        }
      ]
    },
    {
      'category': 'beauty',
      'imageUrlCreateBy':
          'https://pbs.twimg.com/profile_images/942755517390139392/wFwE6JDG_400x400.jpg',
      'createBy': 'admin 003',
      'data': [
        {
          'createBy': 'baifernbarr',
          'imageUrlCreateBy':
              'https://pbs.twimg.com/profile_images/942755517390139392/wFwE6JDG_400x400.jpg',
          'media': "text",
          'title': "I guess you'd love to see more of our food. That's great.",
          'caption': 'click!!',
          'linkUrl': "https://www.youtube.com/watch?v=2Tr1zbrY6y0",
        },
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _futureModel,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return screen(snapshot.data);
          } else if (snapshot.hasError) {
            return Container();
          } else {
            return Container();
          }
        },
      ),
    );
  }

  screen(dynamic model) {
    return Container();
    // return PageView.builder(
    //   itemCount: model.length,
    //   controller: _pageController,
    //   itemBuilder: (context, index) {
    //     return StoryView(
    //       createBy: model[index]['createBy'] != null
    //           ? '${model[index]['createBy']}'
    //           : '',
    //       imageUrlCreateBy: model[index]['imageUrlCreateBy'] != null
    //           ? '${model[index]['imageUrlCreateBy']}'
    //           : '',
    //       storyItems: model.map<StoryItem>((e) {
    //         return StoryItem.pageImage(
    //           url: e['imageUrl'],
    //           caption: e['textButton'],
    //           controller: storyController,
    //           duration: Duration(seconds: 5),
    //           linkUrl: e['linkUrl'],
    //         );
    //       }).toList(),
    //       inline: true,
    //       onVerticalSwipeComplete: (value) => Navigator.pop(context),
    //       onStoryShow: (s) {
    //         print("onStoryShow");
    //       },
    //       onComplete: () {
    //         print("Completed a cycle");
    //         scrollPage(index, model.length - 1);
    //       },
    //       progressPosition: ProgressPosition.top,
    //       repeat: false,
    //       controller: storyController,
    //     );
    //     return StoryView(
    //       inline: true,
    //       onVerticalSwipeComplete: (value) => Navigator.pop(context),
    //       storyItems: [
    //         StoryItem.text(
    //           title: "Nice!\n\nTap to continue.",
    //           backgroundColor: Colors.red,
    //           textStyle: TextStyle(
    //             fontFamily: 'Dancing',
    //             fontSize: 40,
    //           ),
    //         ),
    //         StoryItem.pageImage(
    //           url:
    //               'https://instagram.fbkk7-3.fna.fbcdn.net/v/t51.2885-15/e35/p1080x1080/132955810_694640917907769_6892066725512493322_n.jpg?_nc_ht=instagram.fbkk7-3.fna.fbcdn.net&_nc_cat=109&_nc_ohc=A3J54cydo3kAX8LDL2n&tp=1&oh=e1911b6f5b537845a600629f9cf7fa26&oe=603B0938',
    //           caption: "Still sampling",
    //           linkUrl: 'https://www.youtube.com/watch?v=2Tr1zbrY6y0',
    //           controller: storyController,
    //         ),
    //         StoryItem.pageVideo(
    //           'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    //           caption: "Working with gifs",
    //           duration: Duration(seconds: 120),
    //           controller: storyController,
    //         ),
    //       ],
    //       onStoryShow: (s) {
    //         print("Showing a story");
    //         if (index == 3) Navigator.pop(context);
    //       },
    //       onComplete: () {
    //         print("Completed a cycle");
    //         scrollPage(index, 3);
    //       },
    //       progressPosition: ProgressPosition.top,
    //       repeat: false,
    //       controller: storyController,
    //     );
    //   },
    // );
  }

  scrollPage(int index, int max) {
    _currentPage = index;
    if (_currentPage < max) {
      _currentPage++;
    } else {
      Navigator.pop(context);
    }

    _pageController.animateToPage(
      _currentPage,
      duration: Duration(milliseconds: 350),
      curve: Curves.easeIn,
    );
  }
}
