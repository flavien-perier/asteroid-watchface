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
        ctx.shadowOffsetX = parent.height * 0.00625
        ctx.shadowOffsetY = parent.height * 0.00625
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
            ctx.textAlign = "right"
            ctx.textBaseline = "right"

            const centerX = width * 0.59375
            const centerY = height / 2
            const verticalOffset = height * 0.12

            const text = twoDigits(hour)
            const fontSize = height * 0.3

            ctx.font = "0 " + fontSize + "px 'JetBrains Mono NL Medium'"
            ctx.fillText(text, centerX, centerY + verticalOffset)
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
            ctx.textAlign = "left"
            ctx.textBaseline = "left"

            const centerX = width * 0.6023
            const centerY = height / 2
            const verticalOffset = height * 0.112

            const text = twoDigits(minute)
            const fontSize = height * 0.15

            ctx.font = "0 " + fontSize + "px 'JetBrains Mono NL Medium'"
            ctx.fillText(text, centerX, centerY + verticalOffset)
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
            ctx.arc(width / 2, height / 2, width / 2.4, -90 * radian, rot * radian, false)
            ctx.lineWidth = width / 20
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
            ctx.textAlign = "center"
            ctx.textBaseline = "middle"

            const centerX = width * 0.5947
            const centerY = height * 0.63
            const verticalOffset = height * 0.05

            const text = date.toUpperCase()
            const fontSize = height * 0.060

            ctx.font = "0 " + fontSize + "px 'JetBrains Mono NL Medium'"
            ctx.fillText(text, centerX, centerY + verticalOffset)
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
            ctx.textAlign = "center"
            ctx.textBaseline = "middle"

            const centerX = width * 0.375
            const centerY = height * 0.3
            const verticalOffset = height * 0.05

            const text = day.toUpperCase()
            const fontSize = height * 0.055

            ctx.font = "0 " + fontSize + "px 'JetBrains Mono NL Medium'"
            ctx.fillText(text, centerX, centerY + verticalOffset)
        }
    }

    Connections {
        target: wallClock
        function onTimeChanged() {
            const minute = wallClock.time.getMinutes()
            
            if (minuteCanvas.minute.equals(minute)) {
                const hour = wallClock.time.getHours()
                const date = wallClock.time.toLocaleString(Qt.locale(), "dd MMMM")

                minuteCanvas.minute = minute
                minuteCanvas.requestPaint()
                minuteArc.minute = minute
                minuteArc.requestPaint()

                if (hourCanvas.hour.equals(hour)) {
                    hourCanvas.hour = hour
                    hourCanvas.requestPaint()
                }

                if (dateCanvas.date.equals(date)) {
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
        hourCanvas.requestPaint()

        minuteCanvas.minute = minute
        minuteCanvas.requestPaint()
        minuteArc.minute = minute
        minuteArc.requestPaint()

        dateCanvas.date = date
        dateCanvas.requestPaint()

        dayCanvas.day = day
        dayCanvas.requestPaint()

        burnInProtectionManager.widthOffset = Qt.binding(function() {
            return width * 0.2
        })
        burnInProtectionManager.heightOffset = Qt.binding(function() {
            return height * 0.2
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
