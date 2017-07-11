//
//  TestsDateWalletList.swift
//  AiLiToolbox
//
//  Created by GorCat on 2017/7/11.
//  Copyright © 2017年 AiLi Toolbox. All rights reserved.
//

import Quick
import Nimble
import AiLiToolbox

class TestsDateWalletList: TestsDate {

    override func spec() {
        resetTimes()
        describe("传入一天之内的时间") {
            let today = TSDate(now: now).dateString(.walletList, nsDate: oneDay as NSDate)
            let yesterday = TSDate(now: now).dateString(.walletList, nsDate: twoDay as NSDate)
            let mon = TSDate(now: now).dateString(.walletList, nsDate: Monday as NSDate)
            let tue = TSDate(now: now).dateString(.walletList, nsDate: Tuesday as NSDate)
            let wed = TSDate(now: now).dateString(.walletList, nsDate: Wednesday as NSDate)
            let thu = TSDate(now: now).dateString(.walletList, nsDate: Thursday as NSDate)
            let fri = TSDate(now: now).dateString(.walletList, nsDate: Friday as NSDate)
            let sat = TSDate(now: now).dateString(.walletList, nsDate: Saturday as NSDate)
            let sun = TSDate(now: now).dateString(.walletList, nsDate: Sunday as NSDate)
            it("将时间戳转换成显示字符串") {
                let oneDayAnswer = "今天\n05.12"
                let yesterday = "昨天\n05.11"
                let monAnswer = "周一\n10.03"
                let tueAnswer = "周二\n10.04"
                let wedAnswer = "周三\n10.05"
                let thuAnswer = "周四\n10.06"
                let friAnswer = "周五\n10.07"
                let satAnswer = "周六\n10.01"
                let sunAnswer = "周日\n10.02"
                expect(today) == oneDayAnswer
                expect(yesterday) == yesterday
                expect(mon) == monAnswer
                expect(tue) == tueAnswer
                expect(wed) == wedAnswer
                expect(thu) == thuAnswer
                expect(fri) == friAnswer
                expect(sat) == satAnswer
                expect(sun) == sunAnswer
            }
        }
    }
}
