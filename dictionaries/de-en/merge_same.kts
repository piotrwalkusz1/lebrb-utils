#!/usr/bin/env kscript

//DEPS org.jetbrains.kotlin:kotlin-stdlib:1.2.0
//KOTLIN_OPTS -J-Xmx6g

val records: MutableMap<String,Pair<MutableSet<String>,MutableSet<String>>> = mutableMapOf()
System.`in`.bufferedReader().lines().forEach {
  val p = it.split(';')
  val pair = records[p[0]]
  if (pair == null) {
    records[p[0]] = Pair(mutableSetOf(p[1]), mutableSetOf(p[2]))
  }
  else {
    if (!pair.first.contains(p[1]) || pair.second.size < 3 ) {
      pair.first.add(p[1])
      pair.second.add(p[2])
    }
  }
}

records.forEach {
  val f = it.value.first.joinToString()
  val s = it.value.second.joinToString()
  println("${it.key};$f;$s")
}
