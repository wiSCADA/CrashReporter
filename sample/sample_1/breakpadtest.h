#ifndef BREAKPADTEST_H
#define BREAKPADTEST_H

#include <QtWidgets/QWidget>
#include "ui_breakpadtest.h"

class BreakPadTest : public QWidget
{
	Q_OBJECT

public:
	BreakPadTest(QWidget *parent = 0);
	~BreakPadTest();

private slots:
	void onButtonClicked();

private:
	Ui::BreakPadTestClass ui;
};

#endif // BREAKPADTEST_H
