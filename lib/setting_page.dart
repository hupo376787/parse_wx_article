import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:theme_manager/theme_manager.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () => {Navigator.of(context).pop()},
        // ),
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  '主题',
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              Row(
                children: [
                  InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: SizedBox(
                      width: 120,
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio(
                            groupValue: 'System',
                            value: 'System',
                            onChanged: (value) {
                              ThemeManager.of(context)
                                  .setBrightness(BrightnessPreference.system);
                            },
                          ),
                          const Text('系统'),
                          const Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Icon(Icons.sync),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      ThemeManager.of(context)
                          .setBrightness(BrightnessPreference.system);
                    },
                  ),
                  InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: SizedBox(
                      width: 120,
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio(
                            groupValue: 'Light',
                            value: 'Light',
                            onChanged: (value) {
                              ThemeManager.of(context)
                                  .setBrightness(BrightnessPreference.light);
                            },
                          ),
                          const Text('亮色'),
                          const Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Icon(Icons.light_mode),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      ThemeManager.of(context)
                          .setBrightness(BrightnessPreference.light);
                    },
                  ),
                  InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: SizedBox(
                      width: 120,
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio(
                            groupValue: 'Dark',
                            value: 'Dark',
                            onChanged: (value) {
                              ThemeManager.of(context)
                                  .setBrightness(BrightnessPreference.dark);
                            },
                          ),
                          const Text('暗色'),
                          const Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Icon(Icons.dark_mode),
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      ThemeManager.of(context)
                          .setBrightness(BrightnessPreference.dark);
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  '关于',
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/icon/image.png',
                  height: MediaQuery.of(context).size.width / 8,
                ),
              ),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    '微信文章图片下载',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
