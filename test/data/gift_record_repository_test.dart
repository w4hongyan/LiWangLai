import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liwanglai/data/database/app_database.dart';
import 'package:liwanglai/data/repositories/gift_record_repository.dart';
import 'package:liwanglai/domain/entities/gift_record.dart';

/// A-1：内存数据库跑 Repository，验证「录入→重新读出来」端到端正确。
void main() {
  late AppDatabase db;
  late GiftRecordRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = GiftRecordRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('upsert + watchByBook 返回同一笔记录（A-1 持久化基线）', () async {
    final record = GiftRecord(
      id: 'r1',
      name: '张晓明',
      relation: '挚友',
      event: '婚礼',
      direction: GiftDirection.received,
      tone: EventTone.red,
      amount: 1200,
      date: DateTime(2026, 5, 11),
      method: '现金',
      book: 'default',
    );
    await repo.upsert(record);

    final list = await repo.watchByBook('default').first;
    expect(list, hasLength(1));
    expect(list.first.id, 'r1');
    expect(list.first.name, '张晓明');
    expect(list.first.amount, 1200);
    expect(list.first.tone, EventTone.red);
    expect(list.first.direction, GiftDirection.received);
  });

  test('softDelete 不再出现在 watchByBook（A-1 软删除）', () async {
    final record = GiftRecord(
      id: 'r2',
      name: '李建国',
      relation: '同事',
      event: '乔迁',
      direction: GiftDirection.given,
      tone: EventTone.red,
      amount: 800,
      date: DateTime(2026, 5, 10),
      method: '现金',
      book: 'default',
    );
    await repo.upsert(record);
    await repo.softDelete('r2');

    final list = await repo.watchByBook('default').first;
    expect(list, isEmpty);
  });

  test('listAll 含软删除，watch 不含（A-1 双语义）', () async {
    final a = GiftRecord(
      id: 'a',
      name: '甲',
      relation: '亲友',
      event: '婚礼',
      direction: GiftDirection.received,
      tone: EventTone.red,
      amount: 100,
      date: DateTime(2026, 1, 1),
      method: '现金',
      book: 'default',
    );
    final b = GiftRecord(
      id: 'b',
      name: '乙',
      relation: '亲友',
      event: '婚礼',
      direction: GiftDirection.received,
      tone: EventTone.red,
      amount: 200,
      date: DateTime(2026, 1, 2),
      method: '现金',
      book: 'default',
    );
    await repo.upsert(a);
    await repo.upsert(b);
    await repo.softDelete('b');

    expect((await repo.listAll(includeDeleted: true)).length, 2);
    expect((await repo.listAll()).length, 1);
    expect((await repo.watchByBook('default').first).length, 1);
  });

  test('金额 / 关系 / 礼台 partial 字段均能往返', () async {
    final record = GiftRecord(
      id: 'q',
      name: '钱伯',
      relation: '至亲',
      event: '白事',
      direction: GiftDirection.received,
      tone: EventTone.white,
      amount: 500,
      date: DateTime(2026, 3, 15),
      method: '礼品',
      book: 'default',
      giftName: '花圈一对',
      partial: true,
    );
    await repo.upsert(record);

    final back = (await repo.watchByBook('default').first).first;
    expect(back.relation, '至亲');
    expect(back.tone, EventTone.white);
    expect(back.amount, 500);
    expect(back.method, '礼品');
    expect(back.giftName, '花圈一对');
    expect(back.partial, isTrue);
  });

  test('白榜礼物与现金混存仍可读', () async {
    final record = GiftRecord(
      id: 'w',
      name: '吴',
      relation: '亲友',
      event: '白事其他',
      direction: GiftDirection.given,
      tone: EventTone.white,
      amount: 0,
      date: DateTime(2026, 3, 15),
      method: '出力',
      book: 'default',
      serviceDescription: '帮忙布置灵堂',
    );
    await repo.upsert(record);

    final back = (await repo.watchByBook('default').first).first;
    expect(back.tone, EventTone.white);
    expect(back.method, '出力');
    expect(back.serviceDescription, '帮忙布置灵堂');
  });
}