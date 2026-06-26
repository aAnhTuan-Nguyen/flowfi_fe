import 'package:flowfi_fe/core/network/api_list_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads a raw array response', () {
    final result = readApiList([
      {'id': 'one'},
    ]);

    expect(result.single['id'], 'one');
  });

  test('reads a data array response', () {
    final result = readApiList({
      'data': [
        {'id': 'one'},
      ],
    });

    expect(result.single['id'], 'one');
  });

  test('reads common paginated wrappers', () {
    final result = readApiList({
      'data': {
        'items': [
          {'id': 'one'},
        ],
      },
    });

    expect(result.single['id'], 'one');
  });

  test('throws when response does not contain a list', () {
    expect(
      () => readApiList({
        'data': {'id': 'one'},
      }),
      throwsFormatException,
    );
  });
}
