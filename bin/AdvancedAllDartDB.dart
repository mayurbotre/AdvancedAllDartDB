import 'dart:web_gl';

import 'package:AdvancedAllDartDB/AdvancedAllDartDB.dart' as AdvancedAllDartDB;
import 'package:sqljocky5/constants.dart';
import 'package:sqljocky5/sqljocky.dart';
import 'package:sqljocky5/utils/buffer.dart';
import 'dart:io';
import 'dart:async';

void main(List<String> arguments) async {
  var pool=new ConnectionPool(
    host:'locatlhost',
    port:3306,
    user:'mayur',
    password:'M@yur123',
    db:'school'
  );
  //var conn = await MySqlConnection.connect(pool);
  var result=await pool.query('Select * from teachers');

  print('Result: ${await result.length} rows');

  var query=await pool.prepare('insert into teachers (name,topic) values(?,?)');
  insert(query,'Bob','Science');
  insert(query,'Marry','Shop');

  var res1=await pool.query('select Name,Topic from teachers');

  await res1.forEach((row){
    print('Name: ${row[0]} Topic: ${row.Topic}');

  });


  var trans=await pool.startTransaction();

  try{
    int id=await insert(pool,'Zazzy','Dart');
    int person=await find(pool,'Mayur');
    await delete(pool, person);
    await trans.commit();
    print('Done');
  }
  catch(err){
    print(err.toString());
    await trans.rollback();
  }
  finally {
    pool.closeConnectionNow();
  }



  //await conn.close();
}

/*void insert(var query,String name,String topic) async {
  var res=await query.execute([name,topic]);
  print('New user id = ${res.insertId}');
}*/

Future<int> find(var pool,String name) async {
  Query query=await pool.prepare('select idteachers from teachers where Name=?');
  Results res=await query.execute([name]);
  Row row=await res.first;
  return row[0];
}
Future<int> insert(var pool,String name, String topic) async {
  Query query=await pool.prepare('insert into teachers (Name,Topic) values(?,?)');
  Results res=await query.execute([name,topic]);
  return res.insertId;
}
Future delete(var pool,int value) async {
  Query query=await pool.prepare('delete from teachers where idteachers=?');
  Results res=await query.execute([value]);
}

