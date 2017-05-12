//
//  TestsDate.swift
//  AiLiToolbox
//
//  Created by GorCat on 2017/5/12.
//  Copyright © 2017年 AiLi Toolbox. All rights reserved.
//

import Quick

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
    }

}
