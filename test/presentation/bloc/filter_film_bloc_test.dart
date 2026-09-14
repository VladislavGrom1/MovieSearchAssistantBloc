import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_search_assistant_bloc/domain/entities/filter_data.dart';
import 'package:movie_search_assistant_bloc/presentation/bloc/filter_film/filter_film_bloc.dart';

void main() {
  group('FilterFilmBloc', () {
    test('initial state is FilterFilmInitial', () {
      expect(FilterFilmBloc().state, isA<FilterFilmInitial>());
    });

    blocTest<FilterFilmBloc, FilterFilmState>(
      'emits [FiltersLoaded] with default filters on LoadFilters',
      build: () => FilterFilmBloc(),
      act: (bloc) => bloc.add(LoadFilters()),
      expect: () => [
        isA<FiltersLoaded>()
            .having((s) => s.country, 'country', isNull)
            .having((s) => s.genre, 'genre', isNull)
            .having((s) => s.years, 'years', 'Все годы'),
      ],
    );

    blocTest<FilterFilmBloc, FilterFilmState>(
      'UpdateFilterValue is ignored when filters have not been loaded yet',
      build: () => FilterFilmBloc(),
      act: (bloc) => bloc.add(
        const UpdateFilterValue(filterType: FilterType.genres, value: 5),
      ),
      expect: () => [],
    );

    blocTest<FilterFilmBloc, FilterFilmState>(
      'updates a single filter value while keeping the others intact',
      build: () => FilterFilmBloc(),
      act: (bloc) {
        bloc.add(LoadFilters());
        bloc.add(const UpdateFilterValue(filterType: FilterType.genres, value: 5));
      },
      expect: () => [
        isA<FiltersLoaded>(),
        isA<FiltersLoaded>()
            .having((s) => s.genre, 'genre', 5)
            .having((s) => s.years, 'years', 'Все годы')
            .having((s) => s.country, 'country', isNull),
      ],
    );

    blocTest<FilterFilmBloc, FilterFilmState>(
      'applying multiple UpdateFilterValue events accumulates the changes',
      build: () => FilterFilmBloc(),
      act: (bloc) {
        bloc.add(LoadFilters());
        bloc.add(const UpdateFilterValue(filterType: FilterType.genres, value: 5));
        bloc.add(const UpdateFilterValue(filterType: FilterType.countries, value: 7));
        bloc.add(const UpdateFilterValue(filterType: FilterType.years, value: '2020-2029'));
      },
      verify: (bloc) {
        final state = bloc.state as FiltersLoaded;
        expect(state.genre, 5);
        expect(state.country, 7);
        expect(state.years, '2020-2029');
        expect(state.yearRange, (2020, 2029));
      },
    );

    blocTest<FilterFilmBloc, FilterFilmState>(
      'ResetFilters brings the state back to defaults',
      build: () => FilterFilmBloc(),
      act: (bloc) {
        bloc.add(LoadFilters());
        bloc.add(const UpdateFilterValue(filterType: FilterType.genres, value: 5));
        bloc.add(ResetFilters());
      },
      verify: (bloc) {
        final state = bloc.state as FiltersLoaded;
        expect(state.genre, isNull);
        expect(state.country, isNull);
        expect(state.years, 'Все годы');
      },
    );

    group('FiltersLoaded.yearRange', () {
      test('returns null when years is "Все годы"', () {
        const state = FiltersLoaded();
        expect(state.yearRange, isNull);
      });

      test('parses a single year into a matching (start, end) tuple', () {
        const state = FiltersLoaded(filters: {FilterType.years: '2015'});
        expect(state.yearRange, (2015, 2015));
      });

      test('parses a decade range like "2000-2009" into a tuple', () {
        const state = FiltersLoaded(filters: {FilterType.years: '2000-2009'});
        expect(state.yearRange, (2000, 2009));
      });
    });
  });
}