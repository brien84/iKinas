//
//  ScheduleTests.swift
//  CinemaTests
//
//  Created by Marius on 2022-12-19.
//  Copyright © 2022 Marius. All rights reserved.
//

import ComposableArchitecture
import XCTest
@testable import iKinas

@MainActor
final class ScheduleTests: XCTestCase {

    func testFilteringDatasource() async {
        let datasource = [
            Previews.createShowing(date: Date(timeIntervalSinceNow: .hour), title: "test0"),
            Previews.createShowing(date: Date(timeIntervalSinceNow: .hour), title: "test0"),
            Previews.createShowing(date: Date(timeIntervalSinceNow: .hour), title: "test1"),
            Previews.createShowing(date: .distantFuture, title: "test2")
        ].convertToIdentifiedArray()

        let state = Schedule.State(datasource: datasource)
        let store = TestStore(initialState: state, reducer: Schedule())

        await store.send(.filterDatasource) {
            var showings = [datasource[0], datasource[1], datasource[2]].convertToIdentifiedArray()
            showings.sort(by: .date)
            $0.showings = showings

            var movies = [datasource[0], datasource[2]].convertToIdentifiedArray()
            movies.sort(by: .title)
            $0.movies = movies
        }
    }

    func testFilteringDatasourceWithEnabledTimeFilter() async {
        let referenceDate = Date(timeIntervalSinceNow: .hour)
        let datasource = [
            Previews.createShowing(date: Date(timeInterval: .hour * 1, since: referenceDate), title: "test0"),
            Previews.createShowing(date: Date(timeInterval: .hour * 2, since: referenceDate), title: "test0"),
            Previews.createShowing(date: Date(timeInterval: .hour * 3, since: referenceDate), title: "test1"),
            Previews.createShowing(date: Date(timeInterval: .hour * 4, since: referenceDate), title: "test2")
        ].convertToIdentifiedArray()

        let startTime = Date(timeInterval: .hour * 2, since: referenceDate)
        let endTime = Date(timeInterval: .hour * 3 + 1, since: referenceDate)
        let timeFilter = TimeFilter(startTime: startTime, endTime: endTime)
        let state = Schedule.State(isTimeFiltering: true, timeFilter: timeFilter, datasource: datasource)
        let store = TestStore(initialState: state, reducer: Schedule())

        await store.send(.filterDatasource) {
            var showings = [datasource[1], datasource[2]].convertToIdentifiedArray()
            showings.sort(by: .date)
            $0.showings = showings

            var movies = [datasource[0], datasource[2]].convertToIdentifiedArray()
            movies.sort(by: .title)
            $0.movies = movies
        }
    }

    func testTogglingTimeFiltering() async {
        let state = Schedule.State()
        let store = TestStore(initialState: state, reducer: Schedule())

        await store.send(.toggleTimeFiltering) {
            $0.isTimeFiltering = true
        }

        await store.send(.toggleTimeFiltering) {
            $0.isTimeFiltering = false
        }
    }

    func testUpdatingDatasourceWhenMovieImageIsFetched() async {
        let datasource = [Previews.createShowing()].convertToIdentifiedArray()
        let movie = datasource.first!
        let state = Schedule.State(datasource: datasource, movies: [movie].convertToIdentifiedArray())
        let store = TestStore(initialState: state, reducer: Schedule())

        await store.send(.movie(id: movie.id, action: .networkImage(.imageClient(.success(UIImage()))))) {
            $0.movies[id: movie.id]!.networkImage.image = UIImage()
            $0.datasource[id: movie.id]?.networkImage = $0.movies[id: movie.id]!.networkImage
        }
    }

    func testUpdatingDatasourceWhenShowingImageIsFetched() async {
        let datasource = [Previews.createShowing()].convertToIdentifiedArray()
        let showing = datasource.first!
        let state = Schedule.State(datasource: datasource, showings: [showing].convertToIdentifiedArray())
        let store = TestStore(initialState: state, reducer: Schedule())

        await store.send(.showing(id: showing.id, action: .networkImage(.imageClient(.success(UIImage()))))) {
            $0.showings[id: showing.id]!.networkImage.image = UIImage()
            $0.datasource[id: showing.id]?.networkImage = $0.showings[id: showing.id]!.networkImage
        }
    }

}
