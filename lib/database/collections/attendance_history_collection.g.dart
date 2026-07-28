// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_history_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAttendanceHistoryCollection on Isar {
  IsarCollection<AttendanceHistory> get attendanceHistorys => this.collection();
}

const AttendanceHistorySchema = CollectionSchema(
  name: r'AttendanceHistory',
  id: -4781199150084731658,
  properties: {
    r'attendanceId': PropertySchema(
      id: 0,
      name: r'attendanceId',
      type: IsarType.long,
    ),
    r'changedAt': PropertySchema(
      id: 1,
      name: r'changedAt',
      type: IsarType.dateTime,
    ),
    r'date': PropertySchema(
      id: 2,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'newStatus': PropertySchema(
      id: 3,
      name: r'newStatus',
      type: IsarType.string,
      enumMap: _AttendanceHistorynewStatusEnumValueMap,
    ),
    r'previousStatus': PropertySchema(
      id: 4,
      name: r'previousStatus',
      type: IsarType.string,
      enumMap: _AttendanceHistorypreviousStatusEnumValueMap,
    ),
    r'subjectId': PropertySchema(
      id: 5,
      name: r'subjectId',
      type: IsarType.long,
    )
  },
  estimateSize: _attendanceHistoryEstimateSize,
  serialize: _attendanceHistorySerialize,
  deserialize: _attendanceHistoryDeserialize,
  deserializeProp: _attendanceHistoryDeserializeProp,
  idName: r'id',
  indexes: {
    r'attendanceId': IndexSchema(
      id: -5047753669473436316,
      name: r'attendanceId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'attendanceId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'subjectId': IndexSchema(
      id: 440306668014799972,
      name: r'subjectId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'subjectId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _attendanceHistoryGetId,
  getLinks: _attendanceHistoryGetLinks,
  attach: _attendanceHistoryAttach,
  version: '3.1.0+1',
);

int _attendanceHistoryEstimateSize(
  AttendanceHistory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.newStatus.name.length * 3;
  bytesCount += 3 + object.previousStatus.name.length * 3;
  return bytesCount;
}

void _attendanceHistorySerialize(
  AttendanceHistory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.attendanceId);
  writer.writeDateTime(offsets[1], object.changedAt);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeString(offsets[3], object.newStatus.name);
  writer.writeString(offsets[4], object.previousStatus.name);
  writer.writeLong(offsets[5], object.subjectId);
}

AttendanceHistory _attendanceHistoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AttendanceHistory();
  object.attendanceId = reader.readLong(offsets[0]);
  object.changedAt = reader.readDateTime(offsets[1]);
  object.date = reader.readDateTime(offsets[2]);
  object.id = id;
  object.newStatus = _AttendanceHistorynewStatusValueEnumMap[
          reader.readStringOrNull(offsets[3])] ??
      AttendanceStatus.present;
  object.previousStatus = _AttendanceHistorypreviousStatusValueEnumMap[
          reader.readStringOrNull(offsets[4])] ??
      AttendanceStatus.present;
  object.subjectId = reader.readLong(offsets[5]);
  return object;
}

P _attendanceHistoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (_AttendanceHistorynewStatusValueEnumMap[
              reader.readStringOrNull(offset)] ??
          AttendanceStatus.present) as P;
    case 4:
      return (_AttendanceHistorypreviousStatusValueEnumMap[
              reader.readStringOrNull(offset)] ??
          AttendanceStatus.present) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AttendanceHistorynewStatusEnumValueMap = {
  r'present': r'present',
  r'absent': r'absent',
  r'medical': r'medical',
  r'gt': r'gt',
  r'holiday': r'holiday',
  r'pending': r'pending',
};
const _AttendanceHistorynewStatusValueEnumMap = {
  r'present': AttendanceStatus.present,
  r'absent': AttendanceStatus.absent,
  r'medical': AttendanceStatus.medical,
  r'gt': AttendanceStatus.gt,
  r'holiday': AttendanceStatus.holiday,
  r'pending': AttendanceStatus.pending,
};
const _AttendanceHistorypreviousStatusEnumValueMap = {
  r'present': r'present',
  r'absent': r'absent',
  r'medical': r'medical',
  r'gt': r'gt',
  r'holiday': r'holiday',
  r'pending': r'pending',
};
const _AttendanceHistorypreviousStatusValueEnumMap = {
  r'present': AttendanceStatus.present,
  r'absent': AttendanceStatus.absent,
  r'medical': AttendanceStatus.medical,
  r'gt': AttendanceStatus.gt,
  r'holiday': AttendanceStatus.holiday,
  r'pending': AttendanceStatus.pending,
};

Id _attendanceHistoryGetId(AttendanceHistory object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _attendanceHistoryGetLinks(
    AttendanceHistory object) {
  return [];
}

void _attendanceHistoryAttach(
    IsarCollection<dynamic> col, Id id, AttendanceHistory object) {
  object.id = id;
}

extension AttendanceHistoryQueryWhereSort
    on QueryBuilder<AttendanceHistory, AttendanceHistory, QWhere> {
  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhere>
      anyAttendanceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'attendanceId'),
      );
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhere>
      anySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'subjectId'),
      );
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension AttendanceHistoryQueryWhere
    on QueryBuilder<AttendanceHistory, AttendanceHistory, QWhereClause> {
  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      attendanceIdEqualTo(int attendanceId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'attendanceId',
        value: [attendanceId],
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      attendanceIdNotEqualTo(int attendanceId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'attendanceId',
              lower: [],
              upper: [attendanceId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'attendanceId',
              lower: [attendanceId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'attendanceId',
              lower: [attendanceId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'attendanceId',
              lower: [],
              upper: [attendanceId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      attendanceIdGreaterThan(
    int attendanceId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'attendanceId',
        lower: [attendanceId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      attendanceIdLessThan(
    int attendanceId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'attendanceId',
        lower: [],
        upper: [attendanceId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      attendanceIdBetween(
    int lowerAttendanceId,
    int upperAttendanceId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'attendanceId',
        lower: [lowerAttendanceId],
        includeLower: includeLower,
        upper: [upperAttendanceId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      subjectIdEqualTo(int subjectId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'subjectId',
        value: [subjectId],
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      subjectIdNotEqualTo(int subjectId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectId',
              lower: [],
              upper: [subjectId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectId',
              lower: [subjectId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectId',
              lower: [subjectId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'subjectId',
              lower: [],
              upper: [subjectId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      subjectIdGreaterThan(
    int subjectId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'subjectId',
        lower: [subjectId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      subjectIdLessThan(
    int subjectId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'subjectId',
        lower: [],
        upper: [subjectId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      subjectIdBetween(
    int lowerSubjectId,
    int upperSubjectId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'subjectId',
        lower: [lowerSubjectId],
        includeLower: includeLower,
        upper: [upperSubjectId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      dateEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      dateNotEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterWhereClause>
      dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AttendanceHistoryQueryFilter
    on QueryBuilder<AttendanceHistory, AttendanceHistory, QFilterCondition> {
  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      attendanceIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attendanceId',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      attendanceIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'attendanceId',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      attendanceIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'attendanceId',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      attendanceIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'attendanceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      changedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'changedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      changedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'changedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      changedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'changedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      changedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'changedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      newStatusEqualTo(
    AttendanceStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      newStatusGreaterThan(
    AttendanceStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'newStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      newStatusLessThan(
    AttendanceStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'newStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      newStatusBetween(
    AttendanceStatus lower,
    AttendanceStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'newStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      newStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'newStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      newStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'newStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      newStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'newStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      newStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'newStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      newStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'newStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      newStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'newStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      previousStatusEqualTo(
    AttendanceStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      previousStatusGreaterThan(
    AttendanceStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'previousStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      previousStatusLessThan(
    AttendanceStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'previousStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      previousStatusBetween(
    AttendanceStatus lower,
    AttendanceStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'previousStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      previousStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'previousStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      previousStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'previousStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      previousStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'previousStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      previousStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'previousStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      previousStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      previousStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'previousStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      subjectIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectId',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      subjectIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectId',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      subjectIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectId',
        value: value,
      ));
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterFilterCondition>
      subjectIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AttendanceHistoryQueryObject
    on QueryBuilder<AttendanceHistory, AttendanceHistory, QFilterCondition> {}

extension AttendanceHistoryQueryLinks
    on QueryBuilder<AttendanceHistory, AttendanceHistory, QFilterCondition> {}

extension AttendanceHistoryQuerySortBy
    on QueryBuilder<AttendanceHistory, AttendanceHistory, QSortBy> {
  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      sortByAttendanceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      sortByAttendanceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      sortByChangedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changedAt', Sort.asc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      sortByChangedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changedAt', Sort.desc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      sortByNewStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newStatus', Sort.asc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      sortByNewStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newStatus', Sort.desc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      sortByPreviousStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousStatus', Sort.asc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      sortByPreviousStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousStatus', Sort.desc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      sortBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      sortBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }
}

extension AttendanceHistoryQuerySortThenBy
    on QueryBuilder<AttendanceHistory, AttendanceHistory, QSortThenBy> {
  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      thenByAttendanceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      thenByAttendanceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attendanceId', Sort.desc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      thenByChangedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changedAt', Sort.asc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      thenByChangedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changedAt', Sort.desc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      thenByNewStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newStatus', Sort.asc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      thenByNewStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'newStatus', Sort.desc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      thenByPreviousStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousStatus', Sort.asc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      thenByPreviousStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousStatus', Sort.desc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      thenBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.asc);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QAfterSortBy>
      thenBySubjectIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectId', Sort.desc);
    });
  }
}

extension AttendanceHistoryQueryWhereDistinct
    on QueryBuilder<AttendanceHistory, AttendanceHistory, QDistinct> {
  QueryBuilder<AttendanceHistory, AttendanceHistory, QDistinct>
      distinctByAttendanceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attendanceId');
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QDistinct>
      distinctByChangedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'changedAt');
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QDistinct>
      distinctByNewStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'newStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QDistinct>
      distinctByPreviousStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'previousStatus',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceHistory, QDistinct>
      distinctBySubjectId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectId');
    });
  }
}

extension AttendanceHistoryQueryProperty
    on QueryBuilder<AttendanceHistory, AttendanceHistory, QQueryProperty> {
  QueryBuilder<AttendanceHistory, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AttendanceHistory, int, QQueryOperations>
      attendanceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attendanceId');
    });
  }

  QueryBuilder<AttendanceHistory, DateTime, QQueryOperations>
      changedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'changedAt');
    });
  }

  QueryBuilder<AttendanceHistory, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceStatus, QQueryOperations>
      newStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'newStatus');
    });
  }

  QueryBuilder<AttendanceHistory, AttendanceStatus, QQueryOperations>
      previousStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previousStatus');
    });
  }

  QueryBuilder<AttendanceHistory, int, QQueryOperations> subjectIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectId');
    });
  }
}
