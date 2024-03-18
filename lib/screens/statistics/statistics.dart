import 'package:flutter/material.dart';
import 'package:gym_buddy_app/config.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/helper.dart';
import 'package:gym_buddy_app/screens/ats_ui_elements/ats_icon_button.dart';
import 'package:gym_buddy_app/screens/statistics/add_workout_session_screen.dart';
import 'package:gym_buddy_app/screens/statistics/single_workout_statistics_screen.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();

    DatabaseHelper.getWeeklyStatistics().then((value) => print(value));
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
        actions: [
          atsIconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddWorkoutSessionScreen()));

              setState(() {});
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('weekly statistics',
                  style: Theme.of(context).textTheme.titleMedium),
              Text('number of workouts: xx'),
              Text('total kg lifted: xx'),
              Text('total time spent: xx hours'),
              const SizedBox(height: 20),
              Text('history', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              FutureBuilder(
                  future: DatabaseHelper.getAllWorkoutSessions(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (!snapshot.hasData) {
                        return const Text('no workout sessions found');
                      } else {
                        if (snapshot.data.length > 0) {
                          return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: ListTile(
                                    onTap: () async {
                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SingleWorkoutStatsisticsScreen(
                                                      workout: snapshot
                                                          .data[index])));

                                      setState(() {});
                                    },
                                    tileColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    title: Text(snapshot.data[index].name),
                                    subtitle: Text(
                                        'at ${snapshot.data[index].startTime!.hour.toString().padLeft(2, '0')}:${snapshot.data[index].startTime!.minute.toString().padLeft(2, '0')} for ${Helper.prettyTime(snapshot.data[index].duration)} - ${Helper.getWeightInCorrectUnit(snapshot.data[index].totalWeightLifted).toStringAsFixed(2)} total ${Config.getUnitAbbreviation()} lifted'),
                                  ),
                                );
                              });
                        } else {
                          return const Text('no workout sessions found');
                        }
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
