//
//  TestsDateNormal.swift
//  AiLiToolbox
//
//  Created by GorCat on 2017/5/12.
//  Copyright © 2017年 AiLi Toolbox. All rights reserved.
//
//  TSDate 的测试类

import Quick
import Nimble
import AiLiToolbox

class TestsDateNormal: TestsDate {

    override func spec() {
        resetTimes()
        describe("传入一天之内的时间") {
            let oneMinuteString = TSDate(now: now).dateString(.normal, nsDate: oneMinute as NSDate)
            let oneHourString = TSDate(now: now).dateString(.normal, nsDate: oneHour as NSDate)
            let oneDayString = TSDate(now: now).dateString(.normal, nsDate: oneDay as NSDate)
            let twoDayString = TSDate(now: now).dateString(.normal, nsDate: twoDay as NSDate)
            let nineDayString = TSDate(now: now).dateString(.normal, nsDate: nineDay as NSDate)
            let nineDayMoreString = TSDate(now: now).dateString(.normal, nsDate: nineDayMore as NSDate)
            it("将时间戳转换成显示字符串") {
                let oneMimuteAnswer = "1分钟内"
                let oneHourStringAnswer = "59分钟前"
                let oneDayAnswer = "10小时前"
                let yesterday = "昨天"
                let nineDayAnswer = "4天前"
                let nineDayMoreAnswer = "10-01"
                expect(oneMinuteString) == oneMimuteAnswer
                expect(oneHourString) == oneHourStringAnswer
                expect(oneDayString) == oneDayAnswer
                expect(twoDayString) == yesterday
                expect(nineDayString) == nineDayAnswer
                expect(nineDayMoreString) == nineDayMoreAnswer
            }
        }
    }
}
