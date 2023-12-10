import QtQuick 2.1

Item {
    function twoDigits(x) {
        if (x < 10) {
            return "0" + x
        }
        return x
    }

    function prepareContext(ctx) {
        ctx.reset()
        ctx.fillStyle = "white"
        ctx.shadowColor = Qt.rgba(0, 0, 0, 0.80)
        ctx.shadowOffsetX = parent.height * 0.006
        ctx.shadowOffsetY = parent.height * 0.006
        ctx.shadowBlur = parent.height * 0.0156
    }

    Canvas {
        id: hourCanvas
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative

        property var hour: 0

        onPaint: {
            const ctx = getContext("2d")
            prepareContext(ctx)
            ctx.textAlign = "left"
            ctx.textBaseline = "left"

            const centerX = parent.width * 0.225
            const centerY = parent.height * 0.62

            const text = twoDigits(hour)
            const fontSize = parent.height * 0.3

            ctx.font = "0 " + fontSize + "px 'JetBrains Mono NL Medium'"
            ctx.fillText(text, centerX, centerY)
        }
    }

    Canvas {
        id: minuteCanvas
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative

        property var minute: 0

        onPaint: {
            const ctx = getContext("2d")
            prepareContext(ctx)
            ctx.textAlign = "right"
            ctx.textBaseline = "right"

            const centerX = parent.width * 0.775
            const centerY = parent.height * 0.612

            const text = twoDigits(minute)
            const fontSize = parent.height * 0.15

            ctx.font = "0 " + fontSize + "px 'JetBrains Mono NL Medium'"
            ctx.fillText(text, centerX, centerY)
        }
    }

    Canvas {
        id: minuteArc
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative

        property var minute: 0

        onPaint: {
            const ctx = getContext("2d")
            const rot = (minute - 15 ) * 6
            const radian = 0.01745

            ctx.reset()
            ctx.beginPath()
            ctx.arc(parent.width / 2, parent.height / 2, parent.width / 2.4, -90 * radian, rot * radian, false)
            ctx.lineWidth = parent.width / 20
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.5)
            ctx.stroke()
        }
    }

    Canvas {
        id: dateCanvas
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative

        property var date: "00 NO"

        onPaint: {
            const ctx = getContext("2d")
            prepareContext(ctx)
            ctx.textAlign = "right"
            ctx.textBaseline = "right"

            const centerX = parent.width * 0.77
            const centerY = parent.height * 0.71

            const text = date.toUpperCase()
            const fontSize = parent.height * 0.06

            ctx.font = "0 " + fontSize + "px 'JetBrains Mono NL Medium'"
            ctx.fillText(text, centerX, centerY)
        }
    }

    Canvas {
        id: dayCanvas
        anchors.fill: parent
        renderStrategy: Canvas.Cooperative

        property var day: "MONDAY"

        onPaint: {
            const ctx = getContext("2d")
            prepareContext(ctx)
            ctx.textAlign = "left"
            ctx.textBaseline = "left"

            const centerX = parent.width * 0.26
            const centerY = parent.height * 0.36

            const text = day.toUpperCase()
            const fontSize = parent.height * 0.055

            ctx.font = "0 " + fontSize + "px 'JetBrains Mono NL Medium'"
            ctx.fillText(text, centerX, centerY)
        }
    }

    Connections {
        target: wallClock
        function onTimeChanged() {
            const minute = wallClock.time.getMinutes()
            
            if (minuteCanvas.minute != minute) {
                const hour = wallClock.time.getHours()
                const date = wallClock.time.toLocaleString(Qt.locale(), "dd MMMM")

                minuteCanvas.minute = minute
                minuteCanvas.requestPaint()
                minuteArc.minute = minute
                minuteArc.requestPaint()

                if (hourCanvas.hour != hour) {
                    hourCanvas.hour = hour
                    hourCanvas.requestPaint()
                }

                if (dateCanvas.date != date) {
                    dateCanvas.date = date
                    dateCanvas.requestPaint()

                    dayCanvas.day = wallClock.time.toLocaleString(Qt.locale(), "dddd")
                    dayCanvas.requestPaint()
                }
            }
        }
    }

    Component.onCompleted: {
        const hour = wallClock.time.getHours()
        const minute = wallClock.time.getMinutes()
        const date = wallClock.time.toLocaleString(Qt.locale(), "dd MMMM")
        const day = wallClock.time.toLocaleString(Qt.locale(), "dddd")

        hourCanvas.hour = hour
        minuteCanvas.minute = minute
        minuteArc.minute = minute
        dateCanvas.date = date
        dayCanvas.day = day

        hourCanvas.requestPaint()
        minuteCanvas.requestPaint()
        minuteArc.requestPaint()
        dateCanvas.requestPaint()
        dayCanvas.requestPaint()

        burnInProtectionManager.parent.widthOffset = Qt.binding(function() {
            return parent.width * 0.2
        })
        burnInProtectionManager.parent.heightOffset = Qt.binding(function() {
            return parent.height * 0.2
        })
    }

    Connections {
        target: localeManager
        function onChangesObserverChanged() {
            hourCanvas.requestPaint()
            minuteCanvas.requestPaint()
            minuteArc.requestPaint()
            dateCanvas.requestPaint()
            dayCanvas.requestPaint()
        }
    }
}
