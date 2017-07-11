//
//  TestsDate.swift
//  AiLiToolbox
//
//  Created by GorCat on 2017/5/12.
//  Copyright © 2017年 AiLi Toolbox. All rights reserved.
//

import Quick
import Nimble
import AiLiToolbox

class TestsDate: QuickSpec {

    /// 作为标准的时间
    var now = Date()
    /// 一分钟之内的时间
    var oneMinute = Date()
    /// 一小时之内的时间
    var oneHour = Date()
    /// 一天之内的时间
    var oneDay = Date()
    /// 1天到2天之内的时间
    var twoDay = Date()
    /// 2天到9天之内的时间
    var nineDay = Date()
    /// 9天以上的时间
    var nineDayMore = Date()
    /// 周一
    var Monday = Date()
    /// 周二
    var Tuesday = Date()
    /// 周三
    var Wednesday = Date()
    /// 周四
    var Thursday = Date()
    /// 周五
    var Friday = Date()
    /// 周六
    var Saturday = Date()
    /// 周日
    var Sunday = Date()

    /// 重置时间
    func resetTimes() {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        now = formatter.date(from: "2017-05-12 10:04:30")!
        oneMinute = formatter.date(from: "2017-05-12 10:03:35")!
        oneHour = formatter.date(from: "2017-05-12 9:05:30")!
        oneDay = formatter.date(from: "2017-05-12 00:04:30")!
        twoDay = formatter.date(from: "2017-05-11 00:04:30")!
        nineDay = formatter.date(from: "2017-05-09 10:04:30")!
        nineDayMore = formatter.date(from: "2016-10-01 10:04:30")!
        Monday = formatter.date(from: "2016-10-03 10:04:30")!
        Tuesday = formatter.date(from: "2016-10-04 10:04:30")!
        Wednesday = formatter.date(from: "2016-10-05 10:04:30")!
        Thursday = formatter.date(from: "2016-10-06 10:04:30")!
        Friday = formatter.date(from: "2016-10-07 10:04:30")!
        Saturday = formatter.date(from: "2016-10-01 10:04:30")!
        Sunday = formatter.date(from: "2016-10-02 10:04:30")!
    }

    override func spec() {
        describe("调用 TSDate 的 convince init() 方法") {

            let aDete = TSDate()

            it("创建成功") {
                expect(aDete).to(beAKindOf(TSDate.self))
            }
        }
    }

}
