#include "breakpadtest.h"

BreakPadTest::BreakPadTest(QWidget *parent)
	: QWidget(parent)
{
	ui.setupUi(this);
	connect(ui.pushButton, SIGNAL(clicked()), this, SLOT(onButtonClicked()));
}

BreakPadTest::~BreakPadTest()
{

}

void BreakPadTest::onButtonClicked()
{
	int *i = NULL;
	*i = 0;
}