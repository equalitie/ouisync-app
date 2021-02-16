import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RepoHeader extends StatelessWidget {
  const RepoHeader({
    this.totalRepos,
    this.totalFiles,
    this.totalConflicts,
    this.totalUsers
});

  final int totalRepos;
  final int totalFiles;
  final int totalConflicts;
  final int totalUsers;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child:
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (totalRepos > 0) ColumnText(
              labelString: "repos:",
              value: totalRepos.toString(),
          ),
          SizedBox(width: 10, height: 0.0,),
          ColumnText(
              labelString: "files:",
              value: totalFiles.toString(),
          ),
          SizedBox(width: 10, height: 0.0,),
          ColumnText(
            labelString: "conflicts",
            value: totalConflicts.toString(),
          ),
          if (totalUsers > 1) SizedBox(width: 10, height: 0.0,),
          if (totalUsers > 1) ColumnText(
            labelString: "users:",
            value: totalUsers.toString(),
          )
        ],
      ),
    );
  }
}

class ColumnText extends StatelessWidget {
  ColumnText({
    this.labelString,
    this.value
});

  final String labelString;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelString,
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 14.0,
                color: Colors.black26,
                fontWeight: FontWeight.bold
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.start,
            style: TextStyle(
                fontSize: 24.0,
                color: Colors.black,
                fontWeight: FontWeight.normal
            ),
          ),
        ]
    );
  }
}