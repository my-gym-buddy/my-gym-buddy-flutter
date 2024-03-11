import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  String prettyTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    return '${hours}h ${minutes.toString().padLeft(2, '0')}m ${remainingSeconds.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('statistics'),
        leading: atsIconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('weekly statistics',
                  style: Theme.of(context).textTheme.titleMedium),
              Text('number of workouts: 3'),
              Text('total kg lifted: 1000'),
              Text('total time spent: 3 hours'),
              const SizedBox(height: 10),
              Text('history', style: Theme.of(context).textTheme.titleMedium),
              FutureBuilder(
                  future: DatabaseHelper.getAllWorkoutSessions(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: Text(snapshot.data[index].name),
                                // start time and duration in hh:mm:ss
                                subtitle: Text(
                                    'at ${snapshot.data[index].startTime!.hour.toString().padLeft(2, '0')}:${snapshot.data[index].startTime!.minute.toString().padLeft(2, '0')} for ${prettyTime(snapshot.data[index].duration)}'),
                              );
                            });
                      } else {
                        return const Text('no workout sessions found');
                      }
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
