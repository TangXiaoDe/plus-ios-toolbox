//
//  TestsDate.swift
//  AiLiToolbox
//
//  Created by GorCat on 2017/5/11.
//  Copyright © 2017年 AiLi Toolbox. All rights reserved.
//
//  TSDate 的测试类

import Quick
import Nimble
import AiLiToolbox

class TestsDateSimple: TestsDate {

    override func spec() {
        resetTimes()
        describe("传入一天之内的时间") {
            let oneMinuteString = TSDate(now: now).dateString(.simple, nsDate: oneMinute as NSDate)
            let oneHourString = TSDate(now: now).dateString(.simple, nsDate: oneHour as NSDate)
            let oneDayString = TSDate(now: now).dateString(.simple, nsDate: oneDay as NSDate)
            let twoDayString = TSDate(now: now).dateString(.simple, nsDate: twoDay as NSDate)
            let nineDayString = TSDate(now: now).dateString(.simple, nsDate: nineDay as NSDate)
            let nineDayMoreString = TSDate(now: now).dateString(.simple, nsDate: nineDayMore as NSDate)
            it("将时间戳转换成显示字符串") {
                let today = "今\n天"
                let yesterday = "昨\n天"
                let nineDayAnswer = "09\n5 月"
                let nineDayMoreAnswer = "01\n10月"
                expect(oneMinuteString) == today
                expect(oneHourString) == today
                expect(oneDayString) == today
                expect(twoDayString) == yesterday
                expect(nineDayString) == nineDayAnswer
                expect(nineDayMoreString) == nineDayMoreAnswer
            }
        }
    }
}
