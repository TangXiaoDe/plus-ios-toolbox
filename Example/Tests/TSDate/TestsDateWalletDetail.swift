//
//  TestsDateWalletDetail.swift
//  AiLiToolbox
//
//  Created by GorCat on 2017/7/11.
//  Copyright © 2017年 AiLi Toolbox. All rights reserved.
//

import Quick
import Nimble
import AiLiToolbox

class TestsDateWalletDetail: TestsDate {
    override func spec() {
        resetTimes()
        describe("传入一天之内的时间") {
            let nineDayString = TSDate(now: now).dateString(.walletDetail, nsDate: nineDay as NSDate)
            it("将时间戳转换成显示字符串") {
                let nineDayAnswer = "2017-05-09 周二 10:04"
                expect(nineDayString) == nineDayAnswer
            }
        }
    }
}
